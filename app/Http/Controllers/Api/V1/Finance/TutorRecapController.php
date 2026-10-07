<?php

namespace App\Http\Controllers\Api\V1\Finance;

use App\Http\Controllers\Controller;
use App\Models\Assessment;
use App\Models\Enrollment;
use App\Models\Session;
use App\Models\Tutor;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Excel;

class TutorRecapController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $month = $request->get('month', now()->format('Y-m'));
        $tutorIds = Ownership::tutorIdsFor($request->user());

        $tutors = Tutor::orderBy('name')
            ->when($tutorIds !== null, fn ($q) => $q->whereIn('id', $tutorIds))
            ->get();

        return $this->ok(['month' => $month, 'rows' => $tutors->map(fn ($tutor) => $this->row($tutor, $month))]);
    }

    public function export(Request $request, Excel $excel)
    {
        $month = $request->get('month', now()->format('Y-m'));
        $tutorIds = Ownership::tutorIdsFor($request->user());

        $tutors = Tutor::orderBy('name')
            ->when($tutorIds !== null, fn ($q) => $q->whereIn('id', $tutorIds))
            ->get();
        $rows = $tutors->map(fn ($tutor) => $this->row($tutor, $month));

        $export = new class($rows) implements FromCollection, WithHeadings
        {
            public function __construct(private $rows) {}

            public function collection()
            {
                return $this->rows->map(fn ($row) => [
                    $row['tutor']['name'], $row['dijadwalkan'], $row['selesai'], $row['dibatalkan'],
                    $row['menggantikan'], $row['absensi_persen'], $row['nilai_persen'], $row['honor'],
                ]);
            }

            public function headings(): array
            {
                return ['Tutor', 'Dijadwalkan', 'Selesai', 'Dibatalkan', 'Menggantikan', '% Absensi', '% Nilai', 'Honor (Rp)'];
            }
        };

        return $excel->download($export, "rekap-tutor-{$month}.xlsx");
    }

    private function row(Tutor $tutor, string $month): array
    {
        $base = Session::with('tutor:id,fee_per_session')->where('session_date', 'like', "{$month}%")
            ->where(fn ($q) => $q->where('tutor_id', $tutor->id)->orWhere('substitute_tutor_id', $tutor->id))
            ->get();

        $dijadwalkan = $base->count();
        $selesai = $base->where('status', 'selesai');
        $dibatalkan = $base->where('status', 'dibatalkan')->count();
        $menggantikan = $base->where('substitute_tutor_id', $tutor->id)->count();

        $lengkap = 0;
        foreach ($selesai as $session) {
            $enrolled = Enrollment::where('school_class_id', $session->school_class_id)->where('status', 'aktif')->count();
            $filled = $session->attendances()->count();
            if ($enrolled > 0 && $filled >= $enrolled) {
                $lengkap++;
            }
        }
        $absensiPersen = $selesai->count() > 0 ? round($lengkap / $selesai->count() * 100, 1) : 0;

        $assessments = Assessment::withCount('grades')
            ->whereHas('schoolClass', fn ($q) => $q->where('tutor_id', $tutor->id))
            ->where('assessment_date', 'like', "{$month}%")->get();
        $nilaiPenuh = 0;
        foreach ($assessments as $assessment) {
            $enrolled = Enrollment::where('school_class_id', $assessment->school_class_id)->where('status', 'aktif')->count();
            if ($enrolled > 0 && $assessment->grades_count >= $enrolled) {
                $nilaiPenuh++;
            }
        }
        $nilaiPersen = $assessments->count() > 0 ? round($nilaiPenuh / $assessments->count() * 100, 1) : 0;

        $honor = 0;
        foreach ($selesai as $session) {
            $honor += $session->substitute_tutor_id === $tutor->id
                ? (int) ($session->tutor->fee_per_session ?? 0)
                : (int) $tutor->fee_per_session;
        }

        return [
            'tutor' => $tutor->only('id', 'name'),
            'dijadwalkan' => $dijadwalkan,
            'selesai' => $selesai->count(),
            'dibatalkan' => $dibatalkan,
            'menggantikan' => $menggantikan,
            'absensi_persen' => $absensiPersen,
            'nilai_persen' => $nilaiPersen,
            'honor' => $honor,
        ];
    }
}
