<?php

namespace App\Http\Controllers\Api\V1\IAM;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\NotificationService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        $q = trim((string) $request->get('q', ''));

        return $this->ok(User::with('roles')->when($q !== '', fn ($query) => $query->where(fn ($inner) => $inner->whereRaw('LOWER(name) LIKE ?', ['%'.strtolower($q).'%'])->orWhereRaw('LOWER(email) LIKE ?', ['%'.strtolower($q).'%'])->orWhere('phone', 'like', '%'.$q.'%')))->latest()->paginate((int) $request->get('per_page', 10)));
    }

    public function show(User $user)
    {
        return $this->ok($user->load('roles'));
    }

    public function store(Request $request, NotificationService $notifications)
    {
        $data = $this->validated($request);
        $user = User::create($data);
        $user->syncRoles($data['roles'] ?? []);
        $notifications->send($user, 'selamat_datang');

        return $this->ok($user->load('roles'), 'User dibuat', 201);
    }

    public function update(Request $request, User $user)
    {
        $data = $this->validated($request, $user);
        if (empty($data['password'])) {
            unset($data['password']);
        }
        $user->update($data);
        if (array_key_exists('roles', $data)) {
            $user->syncRoles($data['roles'] ?? []);
        }

        return $this->ok($user->load('roles'), 'User diperbarui');
    }

    public function destroy(User $user)
    {
        $user->delete();

        return $this->ok(null, 'User dihapus');
    }

    private function validated(Request $request, ?User $user = null): array
    {
        return $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'.($user ? ','.$user->id : '')],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone'.($user ? ','.$user->id : '')],
            'avatar_url' => ['nullable', 'string', 'max:2048'],
            'password' => [$user ? 'nullable' : 'required', 'string', 'min:8'],
            'roles' => ['array'],
            'roles.*' => ['string', 'exists:roles,name'],
        ], [
            'phone.unique' => 'Nomor HP sudah dipakai.',
            'email.unique' => 'Email sudah dipakai.',
            'password.min' => 'Kata sandi minimal 8 karakter.',
        ]);
    }
}
