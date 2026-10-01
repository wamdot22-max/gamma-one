<?php

namespace App\Http\Controllers\Api\V1\Academic;

use App\Http\Controllers\Controller;
use App\Models\Grade;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class GradeController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $studentIds = Ownership::studentIdsFor($request->user());
        $classIds = Ownership::classIdsFor($request->user());

        $query = Grade::with(['assessment:id,title,type,assessment_date,school_class_id,subject_id', 'student:id,name,nis'])
            ->orderByDesc('id');
        if ($studentIds !== null) {
            $query->whereIn('student_id', $studentIds);
        }
        if ($classIds !== null) {
            $query->whereHas('assessment', fn ($q) => $q->whereIn('school_class_id', $classIds));
        }
        foreach (['student_id', 'assessment_id'] as $filter) {
            if ($request->get($filter)) {
                $query->where($filter, $request->get($filter));
            }
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 20)));
    }

    /**
     * Rata-rata dan grafik perkembangan nilai per siswa per mapel.
     */
    public function averages(Request $request)
    {
        $data = $request->validate([
            'student_id' => ['required', 'exists:students,id'],
            'subject_id' => ['nullable', 'exists:subjects,id'],
        ]);

        $studentIds = Ownership::studentIdsFor($request->user());
        if ($studentIds !== null && ! in_array((int) $data['student_id'], $studentIds)) {
            abort(404);
        }

        $grades = Grade::with(['assessment:id,title,type,assessment_date,subject_id,school_class_id,weight'])
            ->where('student_id', $data['student_id'])
            ->when(! empty($data['subject_id']), fn ($q) => $q->whereHas('assessment', fn ($x) => $x->where('subject_id', $data['subject_id'])))
            ->get();

        $classIds = Ownership::classIdsFor($request->user());
        if ($classIds !== null) {
            $grades = $grades->filter(fn ($grade) => in_array($grade->assessment->school_class_id, $classIds));
        }

        $bySubject = $grades->groupBy(fn ($grade) => $grade->assessment->subject_id ?? 0)->map(function ($group) {
            $weightSum = $group->sum(fn ($grade) => (float) $grade->assessment->weight);
            $avg = $weightSum > 0
                ? $group->sum(fn ($grade) => (float) $grade->score * (float) $grade->assessment->weight) / $weightSum
                : 0;

            return [
                'subject' => $group->first()->assessment->subject ?? ['id' => null, 'name' => 'Tanpa mapel'],
                'average' => round($avg, 2),
                'count' => $group->count(),
                'trend' => $group->sortBy('assessment.assessment_date')->values()->map(fn ($grade) => [
                    'date' => $grade->assessment->assessment_date,
                    'title' => $grade->assessment->title,
                    'score' => (float) $grade->score,
                ]),
            ];
        })->values();

        return $this->ok(['subjects' => $bySubject]);
    }
}
