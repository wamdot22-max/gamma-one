<?php

namespace App\Http\Controllers\Api\V1\IAM;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class PermissionController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $perPage = (int) $request->get('per_page', 20);
        $q = trim((string) $request->get('q', ''));
        $roleName = trim((string) $request->get('role', ''));

        $query = Permission::with(['roles'])->latest();

        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->whereRaw('LOWER(name) LIKE ?', [$qLike]);
        }

        if ($roleName !== '') {
            $query->whereHas('roles', function ($x) use ($roleName) {
                $x->where('name', $roleName);
            });
        }

        return $this->ok($query->paginate($perPage));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|unique:permissions,name',
            'permission_group_id' => 'nullable|exists:permission_groups,id',
            'roles' => 'array',
            'roles.*' => 'string|exists:roles,name',
        ]);

        $permission = Permission::create([
            'name' => $data['name'],
            'permission_group_id' => $data['permission_group_id'] ?? null,
            'guard_name' => 'web',
        ]);

        if (! empty($data['roles'])) {
            $permission->syncRoles($data['roles']);
        }

        return $this->ok($permission->load(['roles']), 'Permission dibuat', 201);
    }

    public function show(Permission $permission)
    {
        return $this->ok($permission->load(['roles']));
    }

    public function update(Request $request, Permission $permission)
    {
        $data = $request->validate([
            'name' => 'required|string|unique:permissions,name,'.$permission->id,
            'permission_group_id' => 'nullable|exists:permission_groups,id',
            'roles' => 'array',
            'roles.*' => 'string|exists:roles,name',
        ]);

        $permission->update([
            'name' => $data['name'],
            'permission_group_id' => $data['permission_group_id'] ?? null,
        ]);

        if (array_key_exists('roles', $data)) {
            $permission->syncRoles($data['roles'] ?? []);
        }

        return $this->ok($permission->load(['roles']), 'Permission diperbarui');
    }

    public function destroy(Permission $permission)
    {
        $permission->delete();

        return $this->ok(null, 'Permission dihapus');
    }

    public function roleOptions()
    {
        return $this->ok(Role::orderBy('name')->get(['name']));
    }
}
