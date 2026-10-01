<?php

namespace App\Http\Controllers\Api\V1\Scheduling;

use App\Http\Controllers\Controller;
use App\Http\Requests\Scheduling\ScheduleRequest;
use App\Models\Schedule;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Services\ScheduleConflictService;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class ScheduleController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $allowed = Ownership::classIdsFor($request->user());

        $query = Schedule::with(['schoolClass:id,name', 'room:id,name'])->orderBy('day_of_week')->orderBy('start_time');
        if ($allowed !== null) {
            $query->whereIn('school_class_id', $allowed);
        }
        if ($request->get('school_class_id')) {
            $query->where('school_class_id', $request->get('school_class_id'));
        }
        if ($request->get('day_of_week')) {
            $query->where('day_of_week', $request->get('day_of_week'));
        }
        if ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->get('is_active'), FILTER_VALIDATE_BOOL));
        }

        // Tutor: hanya jadwal kelas sendiri (Utama) + jadwal yang persis
        // disubstitusikan (Pengganti). Jadwal lain di kelas yang digantikan
        // ikut tersembunyi; tutor tanpa kelas (cadangan) hanya melihat
        // jadwal penggantinya.
        $subScheduleIds = $this->substitutedScheduleIds($request->user());
        if ($request->user()->hasRole('tutor') && ! Ownership::isPrivileged($request->user())) {
            $ownClassIds = SchoolClass::where('tutor_id', Ownership::tutorRecord($request->user())?->id)->pluck('id')->all();
            $query->where(fn ($q) => $q
                ->whereIn('school_class_id', $ownClassIds === [] ? [-1] : $ownClassIds)
                ->orWhereIn('id', $subScheduleIds === [] ? [-1] : $subScheduleIds));
        }
        if ($request->get('peran') === 'pengganti') {
            $query->whereIn('id', $subScheduleIds === [] ? [-1] : $subScheduleIds);
        } elseif ($request->get('peran') === 'utama') {
            $query->whereNotIn('id', $subScheduleIds);
        }

        $schedules = $query->paginate((int) $request->get('per_page', 50));
        $flip = array_flip($subScheduleIds);
        $schedules->getCollection()->transform(fn ($schedule) => tap($schedule, fn ($item) => $item->peran = isset($flip[$item->id]) ? 'pengganti' : 'utama'));

        return $this->ok($schedules);
    }

    public function weekly(Request $request)
    {
        $request->validate(['school_class_id' => ['nullable', 'exists:school_classes,id']]);
        $allowed = Ownership::classIdsFor($request->user());

        $query = Schedule::with(['schoolClass:id,name', 'room:id,name'])
            ->where('is_active', true)->orderBy('day_of_week')->orderBy('start_time');
        if ($allowed !== null) {
            $query->whereIn('school_class_id', $allowed);
        }
        if ($request->get('school_class_id')) {
            $query->where('school_class_id', $request->get('school_class_id'));
        }

        if ($request->user()->hasRole('tutor') && ! Ownership::isPrivileged($request->user())) {
            $ownClassIds = SchoolClass::where('tutor_id', Ownership::tutorRecord($request->user())?->id)->pluck('id')->all();
            $subIds = $this->substitutedScheduleIds($request->user());
            $query->where(fn ($q) => $q
                ->whereIn('school_class_id', $ownClassIds === [] ? [-1] : $ownClassIds)
                ->orWhereIn('id', $subIds === [] ? [-1] : $subIds));
        }

        $schedules = $query->get();
        $flip = array_flip($this->substitutedScheduleIds($request->user()));
        $schedules->transform(fn ($schedule) => tap($schedule, function ($item) use ($flip) {
            $item->peran = isset($flip[$item->id]) ? 'pengganti' : 'utama';
        }));
        if ($request->get('peran')) {
            $schedules = $schedules->filter(fn ($schedule) => $schedule->peran === $request->get('peran'))->values();
        }

        return $this->ok($schedules->groupBy('day_of_week'));
    }

    public function show(Request $request, Schedule $schedule)
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($schedule->school_class_id, $allowed)) {
            abort(404);
        }

        $schedule->peran = in_array($schedule->id, $this->substitutedScheduleIds($request->user())) ? 'pengganti' : 'utama';

        return $this->ok($schedule->load(['schoolClass', 'room']));
    }

    /**
     * Id jadwal yang memiliki sesi aktif digantikan oleh tutor user ini.
     */
    private function substitutedScheduleIds($user): array
    {
        if (Ownership::isPrivileged($user) || ! $user->hasRole('tutor')) {
            return [];
        }
        $tutorId = Ownership::tutorRecord($user)?->id;
        if (! $tutorId) {
            return [];
        }

        return Session::where('substitute_tutor_id', $tutorId)
            ->where('status', '!=', 'dibatalkan')
            ->whereNotNull('schedule_id')
            ->distinct()->pluck('schedule_id')->all();
    }

    public function store(ScheduleRequest $request, ScheduleConflictService $conflicts)
    {
        $data = $request->validated();
        $problems = $conflicts->checkSchedule($data);
        if ($problems !== []) {
            return $this->fail($problems[0]['message'], 422, $problems);
        }

        return $this->ok(Schedule::create($data), 'Jadwal dibuat', 201);
    }

    public function update(ScheduleRequest $request, Schedule $schedule, ScheduleConflictService $conflicts)
    {
        $data = $request->validated();
        $problems = $conflicts->checkSchedule($data, $schedule->id);
        if ($problems !== []) {
            return $this->fail($problems[0]['message'], 422, $problems);
        }

        $schedule->update($data);

        return $this->ok($schedule->fresh(), 'Jadwal diperbarui');
    }

    public function destroy(Schedule $schedule)
    {
        $schedule->delete();

        return $this->ok(null, 'Jadwal dihapus');
    }
}
