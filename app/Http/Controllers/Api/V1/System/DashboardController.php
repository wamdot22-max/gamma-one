<?php

namespace App\Http\Controllers\Api\V1\System;

use App\Http\Controllers\Controller;
use App\Models\Assessment;
use App\Models\Attendance;
use App\Models\Enrollment;
use App\Models\Grade;
use App\Models\Invoice;
use App\Models\Menu;
use App\Models\Payment;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\SessionSubstituteRequest;
use App\Models\Student;
use App\Models\User;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class DashboardController extends Controller
{
    use ApiResponse;

    public function summary(Request $request)
    {
        $user = $request->user();

        // Hanya tampilkan angka yang memang boleh dilihat perannya,
        // agar tutor/siswa/orang tua tidak mengintip statistik admin.
        $basic = [
            'role' => $user->getRoleNames()->first(),
            'users' => $user->can('users.view') ? User::count() : 0,
            'roles' => $user->can('roles.view') ? Role::count() : 0,
            'permissions' => $user->can('permissions.view') ? Permission::count() : 0,
            'menus' => $user->can('menus.view') ? Menu::count() : 0,
        ];

        if (! $user->hasAnyRole(['super-admin', 'admin', 'staf'])) {
            if ($user->hasRole('tutor')) {
                return $this->ok($basic + $this->tutorStats($user));
            }

            return $this->ok($basic);
        }

        // Cache singkat 2 menit: angka dashboard boleh sedikit basi.
        $stats = Cache::remember('dashboard:admin:v2', 120, function () {
            $now = Carbon::now('Asia/Jakarta');
            $month = $now->format('Y-m');
            $today = $now->toDateString();

            $incomeMonth = (int) Payment::where('paid_at', 'like', "{$month}%")->sum('amount');

            $overdue = Invoice::whereIn('status', ['belum_bayar', 'sebagian'])->whereDate('due_date', '<', $today);
            $overdueCount = $overdue->count();
            $overdueTotal = (int) $overdue->sum(DB::raw('total - paid_amount'));

            $sessionIds = Session::where('status', '!=', 'dibatalkan')
                ->where('session_date', 'like', "{$month}%")->pluck('id');
            $marks = Attendance::whereIn('session_id', $sessionIds)->get();
            $attendanceRate = $marks->count() > 0 ? round($marks->where('status', 'hadir')->count() / $marks->count() * 100, 1) : 0;

            $chart = [];
            for ($i = 5; $i >= 0; $i--) {
                $m = $now->copy()->subMonthsNoOverflow($i)->format('Y-m');
                $chart[] = ['month' => $m, 'total' => (int) Payment::where('paid_at', 'like', "{$m}%")->sum('amount')];
            }

            $topClasses = SchoolClass::withCount(['activeEnrollments'])
                ->orderByDesc('active_enrollments_count')->limit(5)
                ->get(['id', 'name']);

            return [
                'siswa_aktif' => Student::where('status', 'aktif')->count(),
                'pemasukan_bulan_ini' => $incomeMonth,
                'tunggakan_jumlah' => $overdueCount,
                'tunggakan_total' => $overdueTotal,
                'tingkat_kehadiran' => $attendanceRate,
                'grafik_pemasukan' => $chart,
                'kelas_teratas' => $topClasses,
            ];
        });

        $todaySessions = Session::with(['schoolClass:id,name', 'tutor:id,name'])
            ->whereDate('session_date', Carbon::now('Asia/Jakarta')->toDateString())
            ->where('status', '!=', 'dibatalkan')
            ->orderBy('start_time')->limit(10)->get();

        $toBill = Invoice::with('student:id,name,nis')->whereIn('status', ['belum_bayar', 'sebagian'])
            ->orderBy('due_date')->limit(10)->get();

        return $this->ok($basic + $stats + [
            'jadwal_hari_ini' => $todaySessions,
            'perlu_ditagih' => $toBill,
        ]);
    }

    /**
     * Ringkasan live untuk tutor: cache per user 2 menit.
     */
    private function tutorStats(User $user): array
    {
        return Cache::remember("dashboard:tutor:{$user->id}", 120, function () use ($user) {
            $now = Carbon::now('Asia/Jakarta');
            $today = $now->toDateString();
            $month = $now->format('Y-m');

            $tutor = Ownership::tutorRecord($user);
            if (! $tutor) {
                return ['kelas_aktif' => 0, 'total_siswa' => 0, 'sesi_minggu_ini' => 0, 'honor_bulan_ini' => 0,
                    'jadwal_hari_ini' => [], 'perlu_perhatian' => [], 'sesi_mendatang' => []];
            }

            $ownClassIds = SchoolClass::where('tutor_id', $tutor->id)->pluck('id')->all();
            $totalSiswa = Enrollment::whereIn('school_class_id', $ownClassIds)
                ->where('status', 'aktif')->distinct()->count('student_id');

            $weekCount = $this->tutorSessions($tutor)
                ->whereDate('session_date', '>=', $today)
                ->whereDate('session_date', '<=', $now->copy()->addDays(7)->toDateString())
                ->count();

            $monthSessions = $this->tutorFinishedSessions($tutor)->with('tutor:id,fee_per_session')
                ->where('session_date', 'like', "{$month}%")->get();
            $honor = 0;
            foreach ($monthSessions as $session) {
                $honor += $session->substitute_tutor_id === $tutor->id
                    ? (int) ($session->tutor->fee_per_session ?? 0)
                    : (int) $tutor->fee_per_session;
            }

            $todaySessions = $this->tutorSessions($tutor)
                ->with(['schoolClass:id,name', 'room:id,name'])->withCount('attendances')
                ->whereDate('session_date', $today)->orderBy('start_time')->limit(10)->get()
                ->map(fn ($s) => $s->only('id', 'start_time', 'end_time', 'status', 'schoolClass', 'room', 'attendances_count')
                    + ['peran' => $s->substitute_tutor_id === $tutor->id ? 'pengganti' : 'utama']);

            $attention = [];
            $missed = $this->tutorSessions($tutor)->with('schoolClass:id,name')
                ->whereDate('session_date', '<', $today)
                ->whereDoesntHave('attendances')
                ->orderByDesc('session_date')->limit(5)->get();
            foreach ($missed as $session) {
                $attention[] = ['jenis' => 'absensi', 'teks' => "Absensi {$session->schoolClass->name} {$session->session_date} belum diisi"];
            }
            $incomplete = Assessment::with('schoolClass:id,name')->withCount('grades')
                ->whereIn('school_class_id', $ownClassIds)->orderByDesc('id')->limit(10)->get();
            foreach ($incomplete as $assessment) {
                $enrolled = Enrollment::where('school_class_id', $assessment->school_class_id)->where('status', 'aktif')->count();
                if ($assessment->grades_count < $enrolled) {
                    $attention[] = ['jenis' => 'nilai', 'teks' => "Nilai {$assessment->title} kurang ".($enrolled - $assessment->grades_count).' siswa'];
                }
                if (count($attention) >= 5) {
                    break;
                }
            }

            $upcoming = $this->tutorSessions($tutor)->with(['schoolClass:id,name', 'room:id,name'])
                ->whereDate('session_date', '>', $today)
                ->whereDate('session_date', '<=', $now->copy()->addDays(7)->toDateString())
                ->orderBy('session_date')->orderBy('start_time')->limit(10)->get()
                ->map(fn ($s) => $s->only('id', 'session_date', 'start_time', 'end_time', 'status', 'schoolClass', 'room')
                    + ['peran' => $s->substitute_tutor_id === $tutor->id ? 'pengganti' : 'utama']);

            $kehadiranPerKelas = SchoolClass::whereIn('id', $ownClassIds)->orderBy('name')->get(['id', 'name'])
                ->map(function ($class) use ($month) {
                    $ids = Session::where('school_class_id', $class->id)
                        ->where('status', '!=', 'dibatalkan')
                        ->where('session_date', 'like', "{$month}%")->pluck('id');
                    $marks = Attendance::whereIn('session_id', $ids)->get();
                    $total = $marks->count();

                    return [
                        'class' => $class->name,
                        'persen' => $total > 0 ? round($marks->where('status', 'hadir')->count() / $total * 100, 1) : 0,
                    ];
                });

            $rataNilaiPerKelas = SchoolClass::whereIn('id', $ownClassIds)->orderBy('name')->get(['id', 'name'])
                ->map(function ($class) use ($month) {
                    $scores = Grade::whereHas('assessment', fn ($q) => $q
                        ->where('school_class_id', $class->id)
                        ->where('assessment_date', 'like', "{$month}%"))->pluck('score');
                    $avg = $scores->count() > 0 ? round($scores->avg(), 1) : 0;

                    return ['class' => $class->name, 'rata_rata' => $avg, 'jumlah' => $scores->count()];
                });

            $usulan = SessionSubstituteRequest::with(['session:id,school_class_id,session_date', 'session.schoolClass:id,name', 'proposedTutor:id,name'])
                ->where('requested_by', $user->id)
                ->orderByDesc('id')->limit(5)->get()
                ->map(fn ($r) => [
                    'id' => $r->id,
                    'sesi' => $r->session?->schoolClass->name.' · '.$r->session?->session_date,
                    'pengganti' => $r->proposedTutor->name ?? '-',
                    'status' => $r->status,
                ]);

            return [
                'kelas_aktif' => count($ownClassIds),
                'total_siswa' => $totalSiswa,
                'sesi_minggu_ini' => $weekCount,
                'honor_bulan_ini' => $honor,
                'jadwal_hari_ini' => $todaySessions,
                'perlu_perhatian' => array_slice($attention, 0, 5),
                'sesi_mendatang' => $upcoming,
                'kehadiran_per_kelas' => $kehadiranPerKelas,
                'rata_nilai_per_kelas' => $rataNilaiPerKelas,
                'usulan_pengganti' => $usulan,
            ];
        });
    }

    private function tutorSessions($tutor)
    {
        return Session::where('status', '!=', 'dibatalkan')
            ->where(fn ($x) => $x->where('tutor_id', $tutor->id)->orWhere('substitute_tutor_id', $tutor->id));
    }

    private function tutorFinishedSessions($tutor)
    {
        return Session::where('status', 'selesai')
            ->where(fn ($x) => $x->where('tutor_id', $tutor->id)->orWhere('substitute_tutor_id', $tutor->id));
    }
}
