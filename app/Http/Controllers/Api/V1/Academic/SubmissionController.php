<?php

namespace App\Http\Controllers\Api\V1\Academic;

use App\Http\Controllers\Controller;
use App\Http\Requests\Academic\SubmissionRequest;
use App\Models\Assignment;
use App\Models\Submission;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class SubmissionController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $studentIds = Ownership::studentIdsFor($request->user());
        $classIds = Ownership::classIdsFor($request->user());

        $query = Submission::with(['assignment:id,title,school_class_id', 'student:id,name,nis'])->orderByDesc('id');
        if ($studentIds !== null) {
            $query->whereIn('student_id', $studentIds);
        }
        if ($classIds !== null) {
            $query->whereHas('assignment', fn ($q) => $q->whereIn('school_class_id', $classIds));
        }
        if ($request->get('assignment_id')) {
            $query->where('assignment_id', $request->get('assignment_id'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 15)));
    }

    public function store(SubmissionRequest $request)
    {
        $data = $request->validated();

        $studentIds = Ownership::studentIdsFor($request->user());
        if ($studentIds !== null && ! in_array((int) $data['student_id'], $studentIds)) {
            return $this->fail('Siswa tidak ditemukan.', 404);
        }
        $assignment = Assignment::findOrFail($data['assignment_id']);
        $classIds = Ownership::classIdsFor($request->user());
        if ($classIds !== null && ! in_array($assignment->school_class_id, $classIds)) {
            return $this->fail('Tugas tidak ditemukan.', 404);
        }

        $submission = Submission::updateOrCreate(
            ['assignment_id' => $data['assignment_id'], 'student_id' => $data['student_id']],
            ['file_url' => $data['file_url'], 'note' => $data['note'] ?? null, 'submitted_at' => now()]
        );

        return $this->ok($submission, 'Pengumpulan tersimpan', 201);
    }

    public function destroy(Submission $submission)
    {
        $submission->delete();

        return $this->ok(null, 'Pengumpulan dihapus');
    }
}
