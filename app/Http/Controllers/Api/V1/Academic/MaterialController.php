<?php

namespace App\Http\Controllers\Api\V1\Academic;

use App\Http\Controllers\Controller;
use App\Http\Requests\Academic\MaterialRequest;
use App\Models\Material;
use App\Support\Ownership;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class MaterialController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $allowed = Ownership::classIdsFor($request->user());

        $query = Material::with('schoolClass:id,name')->orderByDesc('id');
        if ($allowed !== null) {
            $query->whereIn('school_class_id', $allowed);
        }
        if ($request->get('school_class_id')) {
            $query->where('school_class_id', $request->get('school_class_id'));
        }

        return $this->ok($query->paginate((int) $request->get('per_page', 15)));
    }

    public function show(Request $request, Material $material)
    {
        $allowed = Ownership::classIdsFor($request->user());
        if ($allowed !== null && ! in_array($material->school_class_id, $allowed)) {
            abort(404);
        }

        return $this->ok($material->load('schoolClass:id,name'));
    }

    public function store(MaterialRequest $request)
    {
        return $this->ok(Material::create($request->validated()), 'Materi dibuat', 201);
    }

    public function update(MaterialRequest $request, Material $material)
    {
        $material->update($request->validated());

        return $this->ok($material->fresh(), 'Materi diperbarui');
    }

    public function destroy(Material $material)
    {
        $material->delete();

        return $this->ok(null, 'Materi dihapus');
    }
}
