<?php

namespace Tests\Feature\Fase1;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PasswordResetTest extends TestCase
{
    use RefreshDatabase;

    public function test_forgot_tidak_membocorkan_user_tak_terdaftar(): void
    {
        $this->postJson('/api/v1/auth/forgot-password', ['identity' => 'takada@dev.local'])
            ->assertOk()
            ->assertJsonPath('success', true);
    }

    public function test_forgot_menyimpan_token_reset(): void
    {
        User::factory()->create(['email' => 'reset@dev.local', 'password' => 'lama12345']);

        $this->postJson('/api/v1/auth/forgot-password', ['identity' => 'reset@dev.local'])->assertOk();

        $this->assertDatabaseHas('password_reset_tokens', ['email' => 'reset@dev.local']);
    }

    public function test_reset_mengganti_kata_sandi(): void
    {
        $user = User::factory()->create(['email' => 'ganti@dev.local', 'password' => 'lama12345']);
        DB::table('password_reset_tokens')->insert([
            'email' => 'ganti@dev.local',
            'token' => Hash::make('token-rahasia'),
            'created_at' => now(),
        ]);

        $this->postJson('/api/v1/auth/reset-password', [
            'email' => 'ganti@dev.local',
            'token' => 'token-rahasia',
            'password' => 'baru12345',
            'password_confirmation' => 'baru12345',
        ])->assertOk();

        $this->assertTrue(Hash::check('baru12345', $user->fresh()->password));
        $this->assertDatabaseMissing('password_reset_tokens', ['email' => 'ganti@dev.local']);
    }

    public function test_reset_ditolak_bila_token_salah(): void
    {
        User::factory()->create(['email' => 'salah@dev.local', 'password' => 'lama12345']);
        DB::table('password_reset_tokens')->insert([
            'email' => 'salah@dev.local',
            'token' => Hash::make('token-asli'),
            'created_at' => now(),
        ]);

        $this->postJson('/api/v1/auth/reset-password', [
            'email' => 'salah@dev.local',
            'token' => 'token-palsu',
            'password' => 'baru12345',
            'password_confirmation' => 'baru12345',
        ])->assertStatus(422);
    }

    public function test_reset_ditolak_bila_token_kedaluwarsa(): void
    {
        User::factory()->create(['email' => 'tua@dev.local', 'password' => 'lama12345']);
        DB::table('password_reset_tokens')->insert([
            'email' => 'tua@dev.local',
            'token' => Hash::make('token-tua'),
            'created_at' => now()->subHours(2),
        ]);

        $this->postJson('/api/v1/auth/reset-password', [
            'email' => 'tua@dev.local',
            'token' => 'token-tua',
            'password' => 'baru12345',
            'password_confirmation' => 'baru12345',
        ])->assertStatus(422);
    }
}
