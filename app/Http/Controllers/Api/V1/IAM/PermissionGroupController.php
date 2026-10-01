<?php

namespace App\Http\Controllers\Api\V1\IAM;

use App\Http\Controllers\Controller;
use App\Models\PermissionGroup;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class PermissionGroupController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        if ($request->boolean('with_permissions')) {
            return $this->ok(PermissionGroup::with(['permissions' => fn ($q) => $q->orderBy('name')])->orderBy('name')->get());
        }

        $perPage = (int) $request->get('per_page', 10);
        $q = $request->get('q');

        $query = PermissionGroup::latest();
        if ($q) {
            $qLike = '%'.strtolower($q).'%';
            $query->where(function ($x) use ($qLike) {
                $x->whereRaw('LOWER(name) LIKE ?', [$qLike])
                    ->orWhereRaw('LOWER(slug) LIKE ?', [$qLike]);
            });
        }

        return $this->ok($query->paginate($perPage));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|unique:permission_groups,name',
            'slug' => 'required|string|unique:permission_groups,slug',
            'description' => 'nullable|string',
        ]);

        return $this->ok(PermissionGroup::create($data), 'Permission group dibuat', 201);
    }

    public function show(PermissionGroup $permission_group)
    {
        return $this->ok($permission_group->load('permissions'));
    }

    public function update(Request $request, PermissionGroup $permission_group)
    {
        $data = $request->validate([
            'name' => 'required|string|unique:permission_groups,name,'.$permission_group->id,
            'slug' => 'required|string|unique:permission_groups,slug,'.$permission_group->id,
            'description' => 'nullable|string',
        ]);

        $permission_group->update($data);

        return $this->ok($permission_group, 'Permission group diperbarui');
    }

    public function destroy(PermissionGroup $permission_group)
    {
        $permission_group->delete();

        return $this->ok(null, 'Permission group dihapus');
    }
}
