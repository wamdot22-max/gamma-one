<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Models\User;
use App\Support\PhoneNumber;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    use ApiResponse;

    public function login(LoginRequest $request)
    {
        $data = $request->validated();
        $identity = trim($data['identity']);

        $user = PhoneNumber::isEmail($identity)
            ? User::with('roles.permissions')->where('email', $identity)->first()
            : User::with('roles.permissions')->where('phone', PhoneNumber::normalize($identity))->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return $this->fail('Email/nomor HP atau kata sandi salah', 401);
        }

        $token = $user->createToken('gamma-one-token', ['*'], $this->tokenExpiration($data['remember'] ?? false));

        return $this->ok($this->payload($user, $token->plainTextToken, $token->accessToken->expires_at), 'Login berhasil');
    }

    public function me(Request $request)
    {
        return $this->ok($this->payload($request->user()->load('roles.permissions')));
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();

        return $this->ok(null, 'Logout berhasil');
    }

    private function payload(User $user, ?string $token = null, ?Carbon $expiresAt = null): array
    {
        return ['token' => $token, 'token_expires_at' => $expiresAt?->toISOString(), 'user' => $user, 'roles' => $user->getRoleNames(), 'permissions' => $user->getAllPermissions()->pluck('name')];
    }

    private function tokenExpiration(bool $remember): ?Carbon
    {
        return $remember ? null : now()->addMinutes(config('session.lifetime'));
    }
}
