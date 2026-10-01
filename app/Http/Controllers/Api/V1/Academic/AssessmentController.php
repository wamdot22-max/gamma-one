<?php

namespace App\Http\Controllers\Api\V1\Academic;

use App\Http\Controllers\Controller;
use App\Http\Requests\Academic\AssessmentRequest;
use App\Http\Requests\Academic\GradeBulkRequest;
use App\Models\Assessment;
use App\Models\Enrollment;
use App\Models\Grade;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AssessmentController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $allowed = Ownership::classIdsFor($request->user());

        $query = Assessment::with(['schoolClass:id,name', 'subject:id,name'])
            ->withCount('grades')->orderByDesc('assessment_date')->orderByDesc('id');
        if ($allowed !== null) {
            $query->whereIn('school_class_id', $allowed);
        }
        if ($request->get('school_class_id')) {
            $query->where('school_class_id', $request->get('school_class_id'));
        }
        if ($request->get('type')) {
            $query->where('type', $request->get('type'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 15)));
    }

    public function show(Request $request, Assessment $assessment)
    {
        $this->assertVisible($request, $assessment);

        return $this->ok($assessment->load(['schoolClass', 'subject', 'grades.student:id,name,nis']));
    }

    public function store(AssessmentRequest $request)
    {
        $this->assertClassVisible($request, (int) $request->validated()['school_class_id']);

        return $this->ok(Assessment::create($request->validated()), 'Asesmen dibuat', 201);
    }

    public function update(AssessmentRequest $request, Assessment $assessment)
    {
        $this->assertVisible($request, $assessment);
        $assessment->update($request->validated());

        return $this->ok($assessment->fresh(), 'Asesmen diperbarui');
    }

    public function destroy(Request $request, Assessment $assessment)
    {
        $this->assertVisible($request, $assessment);
        $assessment->delete();

        return $this->ok(null, 'Asesmen dihapus');
    }

    /**
     * Input nilai bulk oleh tutor untuk satu asesmen.
     */
    public function storeGrades(GradeBulkRequest $request, Assessment $assessment)
    {
        $this->assertVisible($request, $assessment);

        $enrolled = Enrollment::where('school_class_id', $assessment->school_class_id)
            ->where('status', 'aktif')->pluck('student_id')->flip();
        foreach ($request->validated()['items'] as $item) {
            if (! $enrolled->has($item['student_id'])) {
                return $this->fail('Ada siswa yang tidak terdaftar di kelas ini.', 422);
            }
        }

        foreach ($request->validated()['items'] as $item) {
            Grade::updateOrCreate(
                ['assessment_id' => $assessment->id, 'student_id' => $item['student_id']],
                ['score' => $item['score'], 'note' => $item['note'] ?? null, 'graded_by' => $request->user()->id]
            );
        }

        return $this->ok(['saved' => count($request->validated()['items'])], 'Nilai tersimpan');
    }

    /**
     * Daftar nilai satu asesmen beserta siswa yang belum dinilai.
     */
    public function grades(Request $request, Assessment $assessment)
    {
        $this->assertVisible($request, $assessment);

        $students = Enrollment::with('student:id,name,nis')->where('school_class_id', $assessment->school_class_id)
            ->where('status', 'aktif')->get()->pluck('student');
        $marked = Grade::where('assessment_id', $assessment->id)->get()->keyBy('student_id');

        return $this->ok([
            'assessment' => $assessment->load(['schoolClass:id,name', 'subject:id,name']),
            'filled' => $marked->count(),
            'total' => $students->count(),
            'items' => $students->map(fn ($student) => [
                'student' => $student,
                'score' => $marked[$student->id]->score ?? null,
                'note' => $marked[$student->id]->note ?? null,
            ]),
        ]);
    }

    private function assertVisible(Request $request, Assessment $assessment): void
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($assessment->school_class_id, $allowed)) {
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
