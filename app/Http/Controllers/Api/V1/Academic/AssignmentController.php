<?php

namespace App\Http\Controllers\Api\V1\Academic;

use App\Http\Controllers\Controller;
use App\Http\Requests\Academic\AssignmentRequest;
use App\Models\Assignment;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AssignmentController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $allowed = Ownership::classIdsFor($request->user());

        $query = Assignment::with('schoolClass:id,name')->withCount('submissions')->orderByDesc('id');
        if ($allowed !== null) {
            $query->whereIn('school_class_id', $allowed);
        }
        if ($request->get('school_class_id')) {
            $query->where('school_class_id', $request->get('school_class_id'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 15)));
    }

    public function show(Request $request, Assignment $assignment)
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($assignment->school_class_id, $allowed)) {
            abort(404);
        }

        return $this->ok($assignment->load(['schoolClass:id,name', 'submissions.student:id,name,nis']));
    }

    public function store(AssignmentRequest $request)
    {
        return $this->ok(Assignment::create($request->validated()), 'Tugas dibuat', 201);
    }

    public function update(AssignmentRequest $request, Assignment $assignment)
    {
        $assignment->update($request->validated());

        return $this->ok($assignment->fresh(), 'Tugas diperbarui');
    }

    public function destroy(Assignment $assignment)
    {
        $assignment->delete();

        return $this->ok(null, 'Tugas dihapus');
    }
}
