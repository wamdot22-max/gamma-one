<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    use ApiResponse;

    public function update(Request $request)
    {
        $user = $request->user();

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,'.$user->id,
            'phone' => 'nullable|string|max:20|unique:users,phone,'.$user->id,
            'avatar_url' => 'nullable|string|max:2048',
            'password' => 'nullable|string|min:8',
        ], [
            'phone.unique' => 'Nomor HP sudah dipakai.',
            'email.unique' => 'Email sudah dipakai.',
            'password.min' => 'Kata sandi minimal 8 karakter.',
        ]);

        if (empty($data['password'])) {
            unset($data['password']);
        }

        $user->update($data);

        return $this->ok($user->load('roles'), 'Profile diperbarui');
    }
}
