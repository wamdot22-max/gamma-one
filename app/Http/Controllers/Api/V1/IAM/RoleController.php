<?php

namespace App\Http\Controllers\Api\V1\IAM;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Role;

class RoleController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $perPage = (int) $request->get('per_page', 10);
        $q = trim((string) $request->get('q', ''));

        $query = Role::with('permissions')->latest();
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->whereRaw('LOWER(name) LIKE ?', [$qLike]);
        }

        return $this->ok($query->paginate($perPage));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|unique:roles,name',
            'permissions' => 'array',
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        $role = Role::create(['name' => $data['name'], 'guard_name' => 'web']);
        if (! empty($data['permissions'])) {
            $role->syncPermissions($data['permissions']);
        }

        return $this->ok($role->load('permissions'), 'Role dibuat', 201);
    }

    public function show(Role $role)
    {
        return $this->ok($role->load('permissions'));
    }

    public function update(Request $request, Role $role)
    {
        $data = $request->validate([
            'name' => 'required|string|unique:roles,name,'.$role->id,
            'permissions' => 'array',
            'permissions.*' => 'string|exists:permissions,name',
        ]);

        $role->update(['name' => $data['name']]);
        if (isset($data['permissions'])) {
            $role->syncPermissions($data['permissions']);
        }

        return $this->ok($role->load('permissions'), 'Role diperbarui');
    }

    public function destroy(Role $role)
    {
        $role->delete();

        return $this->ok(null, 'Role dihapus');
    }
}
