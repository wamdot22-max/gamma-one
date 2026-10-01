<?php

namespace Tests\Feature\Fase1;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PhoneLoginTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_dengan_email(): void
    {
        User::factory()->create(['email' => 'ph1@dev.local', 'phone' => '628111111111', 'password' => 'password123']);

        $this->postJson('/api/v1/auth/login', ['identity' => 'ph1@dev.local', 'password' => 'password123'])
            ->assertOk()
            ->assertJsonPath('success', true);
    }

    public function test_login_dengan_nomor_hp_format_08(): void
    {
        User::factory()->create(['email' => 'ph2@dev.local', 'phone' => '6282222222222', 'password' => 'password123']);

        $this->postJson('/api/v1/auth/login', ['identity' => '082222222222', 'password' => 'password123'])
            ->assertOk()
            ->assertJsonPath('success', true);
    }

    public function test_login_dengan_nomor_hp_format_62(): void
    {
        User::factory()->create(['email' => 'ph3@dev.local', 'phone' => '628333333333', 'password' => 'password123']);

        $this->postJson('/api/v1/auth/login', ['identity' => '628333333333', 'password' => 'password123'])
            ->assertOk();
    }

    public function test_login_gagal_bila_kata_sandi_salah(): void
    {
        User::factory()->create(['email' => 'ph4@dev.local', 'phone' => '628444444444', 'password' => 'benar123']);

        $this->postJson('/api/v1/auth/login', ['identity' => '084444444444', 'password' => 'salah123'])
            ->assertUnauthorized();
    }

    public function test_nomor_hp_dinormalisasi_ke_format_62(): void
    {
        $user = User::factory()->create(['email' => 'ph5@dev.local', 'phone' => '085555555555']);

        $this->assertSame('6285555555555', $user->fresh()->phone);
    }
}
