<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Models\User;
use App\Support\PhoneNumber;
use App\Traits\ApiResponse;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class PasswordResetController extends Controller
{
    use ApiResponse;

    public function forgot(ForgotPasswordRequest $request)
    {
        $identity = trim($request->validated()['identity']);

        $user = PhoneNumber::isEmail($identity)
            ? User::where('email', $identity)->first()
            : User::where('phone', PhoneNumber::normalize($identity))->first();

        // Selalu balas sukses agar tidak membocorkan user mana yang terdaftar.
        if (! $user) {
            return $this->ok(null, 'Jika data terdaftar, tautan reset akan dikirim.');
        }

        $token = Str::random(64);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $user->email],
            ['token' => Hash::make($token), 'created_at' => now()]
        );

        Log::info('Reset kata sandi diminta.', ['email' => $user->email]);

        $payload = null;
        if (config('app.env') === 'local' || config('app.debug')) {
            $payload = ['email' => $user->email, 'token' => $token];
        }

        return $this->ok($payload, 'Jika data terdaftar, tautan reset akan dikirim.');
    }

    public function reset(ResetPasswordRequest $request)
    {
        $data = $request->validated();

        $record = DB::table('password_reset_tokens')->where('email', $data['email'])->first();

        if (! $record || ! Hash::check($data['token'], $record->token)) {
            return $this->fail('Token tidak valid.', 422);
        }

        if (Carbon::parse($record->created_at)->addHour()->isPast()) {
            return $this->fail('Token kedaluwarsa. Minta tautan baru.', 422);
        }

        $user = User::where('email', $data['email'])->firstOrFail();
        $user->update(['password' => $data['password']]);
        $user->tokens()->delete();

        DB::table('password_reset_tokens')->where('email', $data['email'])->delete();

        return $this->ok(null, 'Kata sandi berhasil diubah. Silakan masuk kembali.');
    }
}
