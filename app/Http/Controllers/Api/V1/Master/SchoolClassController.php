<?php

namespace App\Http\Controllers\Api\V1\Master;

use App\Http\Controllers\Controller;
use App\Http\Requests\Master\SchoolClassRequest;
use App\Models\SchoolClass;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class SchoolClassController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));
        $allowed = Ownership::classIdsFor($request->user());

        $query = SchoolClass::with(['program:id,name', 'subject:id,name', 'tutor:id,name', 'room:id,name'])
            ->withCount('activeEnrollments')->orderBy('name');
        if ($allowed !== null) {
            $query->whereIn('id', $allowed);
        }
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(fn ($x) => $x->whereRaw('LOWER(name) LIKE ?', [$qLike]));
        }
        if ($request->has('type')) {
            $query->where('type', $request->get('type'));
        }
        if ($request->get('tutor_id')) {
            $query->where('tutor_id', $request->get('tutor_id'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 10)));
    }

    public function show(Request $request, SchoolClass $class)
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($class->id, $allowed)) {
            abort(404);
        }

        return $this->ok($class->load(['program', 'subject', 'tutor', 'room', 'enrollments.student:id,name,nis']));
    }

    public function store(SchoolClassRequest $request)
    {
        return $this->ok(SchoolClass::create($request->validated()), 'Kelas dibuat', 201);
    }

    public function update(SchoolClassRequest $request, SchoolClass $class)
    {
        $class->update($request->validated());

        return $this->ok($class->fresh(), 'Kelas diperbarui');
    }

    public function destroy(SchoolClass $class)
    {
        $class->delete();

        return $this->ok(null, 'Kelas dihapus');
    }
}
