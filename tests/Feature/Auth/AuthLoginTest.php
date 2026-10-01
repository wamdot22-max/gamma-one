<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class AuthLoginTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_without_remember_sets_token_expiration(): void
    {
        Carbon::setTestNow('2026-07-15 10:00:00');

        $user = User::factory()->create([
            'email' => 'tester@example.com',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'identity' => $user->email,
            'password' => 'password',
            'remember' => false,
        ]);

        $response->assertOk();
        $response->assertJsonPath('data.token_expires_at', now()->addMinutes(config('session.lifetime'))->toISOString());

        $token = $user->tokens()->latest('id')->first();

        $this->assertNotNull($token);
        $this->assertNotNull($token->expires_at);
        $this->assertTrue(
            $token->expires_at->equalTo(now()->addMinutes(config('session.lifetime')))
        );

        Carbon::setTestNow();
    }

    public function test_login_with_remember_keeps_token_without_expiration(): void
    {
        $user = User::factory()->create([
            'email' => 'remember@example.com',
            'password' => 'password',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'identity' => $user->email,
            'password' => 'password',
            'remember' => true,
        ]);

        $response->assertOk();
        $response->assertJsonPath('data.token_expires_at', null);

        $token = $user->tokens()->latest('id')->first();

        $this->assertNotNull($token);
        $this->assertNull($token->expires_at);
    }
}
