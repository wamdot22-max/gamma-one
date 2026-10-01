<?php

namespace App\Http\Controllers\Api\V1\System;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MenuController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $perPage = (int) $request->get('per_page', 20);
        $q = trim((string) $request->get('q', ''));
        $isActive = $request->get('is_active');

        $query = Menu::with('parent')->orderBy('sort_order');
        if ($q !== '') {
            $qLike = '%'.strtolower($q).'%';
            $query->where(function ($x) use ($qLike) {
                $x->whereRaw('LOWER(name) LIKE ?', [$qLike])
                    ->orWhereRaw('LOWER(path) LIKE ?', [$qLike])
                    ->orWhereRaw('LOWER(icon) LIKE ?', [$qLike])
                    ->orWhereHas('parent', fn ($p) => $p->whereRaw('LOWER(name) LIKE ?', [$qLike]));
            });
        }
        if ($isActive !== null && $isActive !== '') {
            $query->where('is_active', filter_var($isActive, FILTER_VALIDATE_BOOL));
        }

        return $this->ok($query->paginate($perPage));
    }

    public function sidebar(Request $request)
    {
        $user = $request->user();
        $permissions = $user->getAllPermissions()->pluck('name')->flip();

        $all = Menu::where('is_active', true)->orderBy('sort_order')->get();
        $allowed = $all->filter(fn ($menu) => $this->matchesMenuPermission($menu->permission_name, $permissions))->values();
        $allowed = $this->hideMenusByRole($user, $allowed);
        $tree = $this->toTree($allowed)->all();
        $pruned = $this->pruneEmptyParents($tree);

        return $this->ok(array_values($pruned));
    }

    /**
     * Siswa/orang tua memakai navigasi portal: sembunyikan Data Master,
     * Penjadwalan, Keuangan, dan Akademik. Tutor tidak melihat Data Master;
     * menu mengajar dan slip honornya tetap tampil. Izin view API tidak diubah.
     */
    private function hideMenusByRole($user, $menus)
    {
        $isStaffLike = $user->hasAnyRole(['super-admin', 'admin', 'staf']);
        if ($isStaffLike) {
            return $menus;
        }

        $hiddenGroups = ['master-data'];
        if ($user->hasAnyRole(['siswa', 'orang_tua'])) {
            $hiddenGroups[] = 'scheduling';
            $hiddenGroups[] = 'finance';
            $hiddenGroups[] = 'academic';
        } elseif (! $user->hasRole('tutor')) {
            return $menus;
        }

        $hiddenPermissions = DB::table('permissions')
            ->join('permission_groups', 'permissions.permission_group_id', '=', 'permission_groups.id')
            ->whereIn('permission_groups.slug', $hiddenGroups)
            ->pluck('permissions.name')
            ->flip();

        return $menus->reject(function ($menu) use ($hiddenPermissions) {
            if (! $menu->permission_name) {
                return false;
            }
            $candidates = collect(explode('|', $menu->permission_name))
                ->map(fn ($permission) => trim($permission))
                ->filter();

            return $candidates->isNotEmpty() && $candidates->every(fn ($permission) => $hiddenPermissions->has($permission));
        })->values();
    }

    private function matchesMenuPermission(?string $permissionName, $permissions): bool
    {
        if (! $permissionName) {
            return true;
        }

        $candidates = collect(explode('|', $permissionName))
            ->map(fn ($permission) => trim($permission))
            ->filter();

        if ($candidates->isEmpty()) {
            return true;
        }

        return $candidates->contains(fn ($permission) => $permissions->has($permission));
    }

    private function toTree($menus)
    {
        $grouped = $menus->groupBy('parent_id');
        $build = function ($parentId) use (&$build, $grouped) {
            return ($grouped[$parentId] ?? collect())->map(function ($menu) use (&$build) {
                return [
                    'id' => $menu->id,
                    'name' => $menu->name,
                    'path' => $menu->path,
                    'icon' => $menu->icon,
                    'children' => $build($menu->id)->values()->all(),
                ];
            })->values();
        };

        return $build(null);
    }

    private function pruneEmptyParents(array $nodes): array
    {
        $result = [];
        foreach ($nodes as $node) {
            $children = $this->pruneEmptyParents($node['children'] ?? []);
            $hasPath = ! empty($node['path']);
            if ($hasPath || ! empty($children)) {
                $node['children'] = $children;
                $result[] = $node;
            }
        }

        return $result;
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'path' => 'nullable|string|max:255',
            'icon' => 'nullable|string|max:255',
            'sort_order' => 'nullable|integer',
            'parent_id' => 'nullable|exists:menus,id',
            'permission_name' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        return $this->ok(Menu::create($data), 'Menu dibuat', 201);
    }

    public function show(Menu $menu)
    {
        return $this->ok($menu->load('parent'));
    }

    public function update(Request $request, Menu $menu)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'path' => 'nullable|string|max:255',
            'icon' => 'nullable|string|max:255',
            'sort_order' => 'nullable|integer',
            'parent_id' => 'nullable|exists:menus,id',
            'permission_name' => 'nullable|string|max:255',
            'is_active' => 'boolean',
        ]);

        $menu->update($data);

        return $this->ok($menu, 'Menu diperbarui');
    }

    public function destroy(Menu $menu)
    {
        $menu->delete();

        return $this->ok(null, 'Menu dihapus');
    }
}
