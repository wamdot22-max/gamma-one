<?php

namespace App\Http\Controllers\Api\V1\Academic;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Grade;
use App\Models\Session;
use App\Models\Student;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class ReportCardController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $data = $request->validate([
            'student_id' => ['required', 'exists:students,id'],
            'month' => ['nullable', 'date_format:Y-m'],
        ]);

        return $this->ok($this->build($request, (int) $data['student_id'], $data['month'] ?? now()->format('Y-m')));
    }

    public function download(Request $request)
    {
        $data = $request->validate([
            'student_id' => ['required', 'exists:students,id'],
            'month' => ['nullable', 'date_format:Y-m'],
        ]);

        $report = $this->build($request, (int) $data['student_id'], $data['month'] ?? now()->format('Y-m'));
        $pdf = Pdf::loadView('pdf.report-card', ['report' => $report]);

        return $pdf->download("rapor-{$report['student']['nis']}-{$report['month']}.pdf");
    }

    private function build(Request $request, int $studentId, string $month): array
    {
        $studentIds = Ownership::studentIdsFor($request->user());
        if ($studentIds !== null && ! in_array($studentId, $studentIds)) {
            abort(404);
        }

        $student = Student::with('guardians:id,name')->findOrFail($studentId);

        $grades = Grade::with(['assessment:id,title,type,assessment_date,subject_id,weight,school_class_id'])
            ->where('student_id', $studentId)
            ->whereHas('assessment', fn ($q) => $q->where('assessment_date', 'like', "{$month}%"))
            ->get();

        $classIds = Ownership::classIdsFor($request->user());
        if ($classIds !== null) {
            $grades = $grades->filter(fn ($grade) => in_array($grade->assessment->school_class_id, $classIds));
        }

        $subjects = $grades->groupBy(fn ($grade) => $grade->assessment->subject_id ?? 0)->map(function ($group) {
            $weightSum = $group->sum(fn ($grade) => (float) $grade->assessment->weight);
            $avg = $weightSum > 0
                ? $group->sum(fn ($grade) => (float) $grade->score * (float) $grade->assessment->weight) / $weightSum
                : 0;

            return [
                'subject' => $group->first()->assessment->subject ?? ['id' => null, 'name' => 'Tanpa mapel'],
                'average' => round($avg, 2),
                'items' => $group->map(fn ($grade) => [
                    'title' => $grade->assessment->title,
                    'type' => $grade->assessment->type,
                    'date' => $grade->assessment->assessment_date,
                    'score' => (float) $grade->score,
                    'note' => $grade->note,
                ])->values(),
            ];
        })->values();

        $sessionIds = Session::where('status', '!=', 'dibatalkan')
            ->where('session_date', 'like', "{$month}%")
            ->when($classIds !== null, fn ($q) => $q->whereIn('school_class_id', $classIds))
            ->pluck('id');
        $marks = Attendance::whereIn('session_id', $sessionIds)->where('student_id', $studentId)->get();
        $attendance = [
            'hadir' => $marks->where('status', 'hadir')->count(),
            'izin' => $marks->where('status', 'izin')->count(),
            'sakit' => $marks->where('status', 'sakit')->count(),
            'alfa' => $marks->where('status', 'alfa')->count(),
        ];

        $notes = $grades->pluck('note')->filter()->unique()->values();

        return [
            'month' => $month,
            'student' => $student->only('id', 'nis', 'name', 'school') + ['guardians' => $student->guardians->pluck('name')->all()],
            'subjects' => $subjects,
            'attendance' => $attendance,
            'tutor_notes' => $notes,
        ];
    }
}
