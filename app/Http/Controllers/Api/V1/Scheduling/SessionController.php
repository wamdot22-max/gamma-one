<?php

namespace App\Http\Controllers\Api\V1\Scheduling;

use App\Http\Controllers\Controller;
use App\Http\Requests\Scheduling\AttendanceRequest;
use App\Http\Requests\Scheduling\SessionCancelRequest;
use App\Http\Requests\Scheduling\SessionGenerateRequest;
use App\Http\Requests\Scheduling\SessionRescheduleRequest;
use App\Models\Attendance;
use App\Models\BlamableLog;
use App\Models\Enrollment;
use App\Models\Schedule;
use App\Models\Session;
use App\Models\Student;
use App\Services\NotificationService;
use App\Services\ScheduleConflictService;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class SessionController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $allowed = Ownership::classIdsFor($request->user());

        $query = Session::with(['schoolClass:id,name,subject_id', 'room:id,name', 'tutor:id,name', 'substitute:id,name'])
            ->withCount('attendances')->orderBy('session_date')->orderBy('start_time');
        if ($allowed !== null) {
            $query->whereIn('school_class_id', $allowed);
        }
        foreach (['school_class_id', 'status', 'tutor_id'] as $filter) {
            if ($request->get($filter)) {
                $query->where($filter, $request->get($filter));
            }
        }
        if ($request->get('from_date')) {
            $query->whereDate('session_date', '>=', $request->get('from_date'));
        }
        if ($request->get('to_date')) {
            $query->whereDate('session_date', '<=', $request->get('to_date'));
        }
        if ($request->boolean('digantikan')) {
            $myTutorId = Ownership::tutorRecord($request->user())?->id ?? -1;
            $query->where('substitute_tutor_id', $myTutorId);
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 20)));
    }

    public function show(Request $request, Session $session)
    {
        $this->assertVisible($request, $session);

        return $this->ok($session->load(['schoolClass', 'room', 'tutor', 'schedule']));
    }

    public function destroy(Request $request, Session $session)
    {
        $this->assertVisible($request, $session);
        $session->delete();

        return $this->ok(null, 'Sesi dihapus');
    }

    /**
     * Generate sesi dari jadwal mingguan untuk rentang tanggal.
     * Idempoten: sesi yang sudah ada dilewati.
     */
    public function generate(SessionGenerateRequest $request)
    {
        $data = $request->validated();
        $this->assertClassVisible($request, (int) $data['school_class_id']);

        $schedules = Schedule::where('school_class_id', $data['school_class_id'])
            ->where('is_active', true)->get();

        $from = Carbon::parse($data['from_date']);
        $to = Carbon::parse($data['to_date']);
        $created = 0;
        $skipped = 0;

        for ($date = $from->copy(); $date->lte($to); $date->addDay()) {
            foreach ($schedules as $schedule) {
                if ((int) $date->dayOfWeekIso !== (int) $schedule->day_of_week) {
                    continue;
                }
                $exists = Session::where('school_class_id', $data['school_class_id'])
                    ->whereDate('session_date', $date->toDateString())
                    ->where('start_time', $schedule->start_time)
                    ->exists();
                if ($exists) {
                    $skipped++;

                    continue;
                }
                $class = $schedule->schoolClass;
                Session::create([
                    'school_class_id' => $data['school_class_id'],
                    'schedule_id' => $schedule->id,
                    'session_date' => $date->toDateString(),
                    'start_time' => $schedule->start_time,
                    'end_time' => $schedule->end_time,
                    'room_id' => $schedule->room_id ?? $class->room_id,
                    'tutor_id' => $class->tutor_id,
                    'status' => 'terjadwal',
                ]);
                $created++;
            }
        }

        return $this->ok(['created' => $created, 'skipped' => $skipped], "Generate selesai: {$created} dibuat, {$skipped} dilewati.", 201);
    }

    public function reschedule(SessionRescheduleRequest $request, Session $session, ScheduleConflictService $conflicts, NotificationService $notifications)
    {
        $this->assertVisible($request, $session);
        if ($session->status === 'dibatalkan') {
            return $this->fail('Sesi yang dibatalkan tidak bisa dijadwal ulang.', 422);
        }
        if ($session->status === 'selesai') {
            return $this->fail('Sesi yang sudah selesai tidak bisa dijadwal ulang.', 422);
        }

        $data = $request->validated();
        $problems = $conflicts->checkSessionReschedule($session, $data);
        if ($problems !== []) {
            return $this->fail($problems[0]['message'], 422, $problems);
        }

        $session->update([
            'session_date' => $data['session_date'],
            'start_time' => $data['start_time'],
            'end_time' => $data['end_time'],
            'room_id' => $data['room_id'] ?? $session->room_id,
            'reason' => $data['reason'],
        ]);
        $session = $session->fresh();

        foreach ($session->activeStudents() as $student) {
            $notifications->notifyParents($student, 'jadwal_berubah', [
                'kelas' => $session->schoolClass->name,
                'tanggal' => $session->session_date->toDateString(),
                'jam' => substr((string) $session->start_time, 0, 5),
                'alasan' => $data['reason'],
            ], $session);
        }

        return $this->ok($session, 'Sesi dijadwal ulang');
    }

    public function cancel(SessionCancelRequest $request, Session $session, NotificationService $notifications)
    {
        $this->assertVisible($request, $session);
        if ($session->status !== 'terjadwal') {
            return $this->fail('Hanya sesi terjadwal yang bisa dibatalkan.', 422);
        }

        $reason = $request->validated()['reason'];
        $session->update(['status' => 'dibatalkan', 'reason' => $reason]);
        $session = $session->fresh();

        foreach ($session->activeStudents() as $student) {
            $notifications->notifyParents($student, 'sesi_batal', [
                'kelas' => $session->schoolClass->name,
                'tanggal' => $session->session_date->toDateString(),
                'alasan' => $reason,
            ], $session);
        }

        return $this->ok($session, 'Sesi dibatalkan');
    }

    /**
     * Riwayat perubahan sesi dari audit log agar terlihat di UI.
     */
    public function history(Request $request, Session $session)
    {
        $this->assertVisible($request, $session);

        $logs = BlamableLog::with('user:id,name')
            ->where('model_type', Session::class)
            ->where('model_id', (string) $session->id)
            ->orderByDesc('id')->limit(50)->get();

        return $this->ok($logs);
    }

    public function attendances(Request $request, Session $session)
    {
        $this->assertVisible($request, $session);

        $students = Enrollment::with('student:id,name,nis')
            ->where('school_class_id', $session->school_class_id)
            ->where('status', 'aktif')->get()->pluck('student');

        $marked = Attendance::where('session_id', $session->id)->get()->keyBy('student_id');

        $items = $students->map(fn ($student) => [
            'student' => $student,
            'status' => $marked[$student->id]->status ?? null,
            'note' => $marked[$student->id]->note ?? null,
        ]);

        return $this->ok([
            'session' => $session->load(['schoolClass:id,name', 'tutor:id,name', 'substitute:id,name']),
            'filled' => $marked->count(),
            'total' => $students->count(),
            'items' => $items,
        ]);
    }

    public function storeAttendances(AttendanceRequest $request, Session $session, NotificationService $notifications)
    {
        $this->assertVisible($request, $session);
        if ($session->status === 'dibatalkan') {
            return $this->fail('Sesi yang dibatalkan tidak bisa diabsen.', 422);
        }
        if ($session->status === 'selesai') {
            return $this->fail('Sesi yang sudah selesai terkunci.', 422);
        }

        $data = $request->validated();
        $enrolled = Enrollment::where('school_class_id', $session->school_class_id)
            ->where('status', 'aktif')->pluck('student_id')->flip();

        foreach ($data['items'] as $item) {
            if (! $enrolled->has($item['student_id'])) {
                return $this->fail('Ada siswa yang tidak terdaftar di kelas ini.', 422);
            }
        }

        foreach ($data['items'] as $item) {
            Attendance::updateOrCreate(
                ['session_id' => $session->id, 'student_id' => $item['student_id']],
                ['status' => $item['status'], 'understanding' => $item['understanding'] ?? null, 'note' => $item['note'] ?? null, 'marked_by' => $request->user()->id]
            );
        }

        foreach ($data['items'] as $item) {
            $student = Student::find($item['student_id']);
            if ($student) {
                $notifications->notifyParents($student, 'kehadiran_ortu', [
                    'status' => $item['status'],
                    'kelas' => $session->schoolClass->name,
                    'tanggal' => $session->session_date->toDateString(),
                ], $session);
            }
        }

        // Pengisi yang merupakan tutor sesi otomatis tercatat hadir;
        // staf/admin yang mengisikan tetap mengisi manual.
        $saverTutorId = Ownership::tutorRecord($request->user())?->id;
        $isOwnTutor = $saverTutorId && in_array($saverTutorId, [$session->tutor_id, $session->substitute_tutor_id]);
        $tutorStatus = $data['tutor_status'] ?? ($isOwnTutor ? 'hadir' : $session->tutor_status);

        $session->update([
            'material_notes' => $data['material_notes'] ?? $session->material_notes,
            'tutor_status' => $tutorStatus,
        ]);

        return $this->ok(['saved' => count($data['items'])], 'Absensi tersimpan');
    }

    /**
     * Tandai sesi selesai. Terkunci setelahnya: absensi, reschedule,
     * batal, dan usul pengganti ditolak.
     */
    public function complete(Request $request, Session $session)
    {
        $this->assertVisible($request, $session);
        if ($session->status !== 'terjadwal') {
            return $this->fail('Hanya sesi terjadwal yang bisa diselesaikan.', 422);
        }

        $enrolled = Enrollment::where('school_class_id', $session->school_class_id)->where('status', 'aktif')->count();
        $filled = $session->attendances()->count();
        if ($filled < $enrolled) {
            return $this->fail("Absensi belum lengkap ({$filled} dari {$enrolled} terisi).", 422);
        }
        if (! trim((string) $session->material_notes)) {
            return $this->fail('Catatan materi wajib diisi sebelum menyelesaikan sesi.', 422);
        }

        $session->update(['status' => 'selesai']);

        return $this->ok($session->fresh(), 'Sesi selesai');
    }

    /**
     * Buka kembali sesi selesai. Khusus admin/staf, wajib alasan.
     */
    public function reopen(Request $request, Session $session)
    {
        $this->assertVisible($request, $session);
        if (! Ownership::isPrivileged($request->user())) {
            return $this->fail('Hanya admin/staf yang boleh membuka kembali sesi.', 403);
        }
        if ($session->status !== 'selesai') {
            return $this->fail('Hanya sesi selesai yang bisa dibuka kembali.', 422);
        }

        $data = $request->validate(['reason' => ['required', 'string', 'max:1000']], ['reason.required' => 'Alasan wajib diisi.']);
        $session->update(['status' => 'terjadwal', 'reason' => $data['reason']]);

        return $this->ok($session->fresh(), 'Sesi dibuka kembali');
    }

    /**
     * Absensi via pindaian: kode = NIS siswa (dari QR kartu siswa).
     */
    public function scan(Request $request, Session $session)
    {
        $this->assertVisible($request, $session);
        if ($session->status === 'dibatalkan') {
            return $this->fail('Sesi yang dibatalkan tidak bisa diabsen.', 422);
        }
        if ($session->status === 'selesai') {
            return $this->fail('Sesi yang sudah selesai terkunci.', 422);
        }

        $data = $request->validate(['code' => ['required', 'string', 'max:30']], ['code.required' => 'Kode pindaian wajib diisi.']);
        $student = Student::where('nis', trim($data['code']))->first();
        if (! $student) {
            return $this->fail('Kode tidak dikenal.', 404);
        }

        $enrolled = Enrollment::where('school_class_id', $session->school_class_id)
            ->where('student_id', $student->id)->where('status', 'aktif')->exists();
        if (! $enrolled) {
            return $this->fail("{$student->name} tidak terdaftar di kelas ini.", 422);
        }

        $attendance = Attendance::updateOrCreate(
            ['session_id' => $session->id, 'student_id' => $student->id],
            ['status' => 'hadir', 'marked_by' => $request->user()->id]
        );

        return $this->ok($attendance->load('student:id,name,nis'), "{$student->name} ditandai hadir");
    }

    private function assertVisible(Request $request, Session $session): void
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($session->school_class_id, $allowed)) {
            abort(404);
        }
    }

    private function assertClassVisible(Request $request, int $classId): void
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($classId, $allowed)) {
            abort(404);
        }
    }
}
