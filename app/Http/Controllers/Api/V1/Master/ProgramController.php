<?php

namespace App\Http\Controllers\Api\V1\Master;

use App\Http\Controllers\Controller;
use App\Http\Requests\Master\ProgramRequest;
use App\Models\Program;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class ProgramController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));

        $query = Program::query()->orderBy('name');
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->whereRaw('LOWER(name) LIKE ?', [$qLike]);
        }
        if ($request->has('is_active')) {
            $query->where('is_active', filter_var($request->get('is_active'), FILTER_VALIDATE_BOOL));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 10)));
    }

    public function show(Program $program)
    {
        return $this->ok($program);
    }

    public function store(ProgramRequest $request)
    {
        return $this->ok(Program::create($request->validated()), 'Program dibuat', 201);
    }

    public function update(ProgramRequest $request, Program $program)
    {
        $program->update($request->validated());

        return $this->ok($program->fresh(), 'Program diperbarui');
    }

    public function destroy(Program $program)
    {
        $program->delete();

        return $this->ok(null, 'Program dihapus');
    }
}
