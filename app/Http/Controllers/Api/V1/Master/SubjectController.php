<?php

namespace App\Http\Controllers\Api\V1\Master;

use App\Http\Controllers\Controller;
use App\Http\Requests\Master\SubjectRequest;
use App\Models\Subject;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));

        $query = Subject::query()->orderBy('name');
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(fn ($x) => $x->whereRaw('LOWER(name) LIKE ?', [$qLike])->orWhereRaw('LOWER(code) LIKE ?', [$qLike]));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 10)));
    }

    public function show(Subject $subject)
    {
        return $this->ok($subject->load('tutors'));
    }

    public function store(SubjectRequest $request)
    {
        return $this->ok(Subject::create($request->validated()), 'Mapel dibuat', 201);
    }

    public function update(SubjectRequest $request, Subject $subject)
    {
        $subject->update($request->validated());

        return $this->ok($subject->fresh(), 'Mapel diperbarui');
    }

    public function destroy(Subject $subject)
    {
        $subject->delete();

        return $this->ok(null, 'Mapel dihapus');
    }
}
