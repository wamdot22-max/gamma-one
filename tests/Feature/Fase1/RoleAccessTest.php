<?php

namespace Tests\Feature\Fase1;

use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RoleAccessTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private function user(string $email): User
    {
        return User::where('email', $email)->firstOrFail();
    }

    public function test_tamu_ditolak_di_endpoint_terlindungi(): void
    {
        $this->getJson('/api/v1/users')->assertUnauthorized();
        $this->getJson('/api/v1/menus/sidebar')->assertUnauthorized();
    }

    public function test_siswa_tidak_bisa_membuka_modul_admin(): void
    {
        $siswa = $this->user('siswa@dev.local');

        $this->actingAs($siswa, 'sanctum')->getJson('/api/v1/users')->assertForbidden();
        $this->actingAs($siswa, 'sanctum')->postJson('/api/v1/users', [
            'name' => 'X', 'email' => 'x@dev.local', 'password' => 'password123',
        ])->assertForbidden();
        $this->actingAs($siswa, 'sanctum')->getJson('/api/v1/blamable-logs')->assertForbidden();
        $this->actingAs($siswa, 'sanctum')->getJson('/api/v1/roles')->assertForbidden();
    }

    public function test_staf_bisa_lihat_tapi_tidak_bisa_buat_user(): void
    {
        $staf = $this->user('staf@dev.local');

        $this->actingAs($staf, 'sanctum')->getJson('/api/v1/users')->assertOk();
        $this->actingAs($staf, 'sanctum')->postJson('/api/v1/users', [
            'name' => 'X', 'email' => 'x@dev.local', 'password' => 'password123',
        ])->assertForbidden();
    }

    public function test_admin_bisa_mengelola_user(): void
    {
        $admin = $this->user('admin.contoh@dev.local');

        $this->actingAs($admin, 'sanctum')->getJson('/api/v1/users')->assertOk();
        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/users', [
            'name' => 'User Baru', 'email' => 'baru@dev.local', 'password' => 'password123',
        ])->assertCreated();
    }

    public function test_orang_tua_tidak_bisa_membuka_data_admin(): void
    {
        $ortu = $this->user('orangtua@dev.local');

        $this->actingAs($ortu, 'sanctum')->getJson('/api/v1/users')->assertForbidden();
        $this->actingAs($ortu, 'sanctum')->getJson('/api/v1/dashboard/summary')->assertOk()
            ->assertJsonPath('data.users', 0);
    }

    public function test_tutor_tidak_melihat_statistik_admin(): void
    {
        $tutor = $this->user('tutor@dev.local');

        $this->actingAs($tutor, 'sanctum')->getJson('/api/v1/dashboard/summary')->assertOk()
            ->assertJsonPath('data.users', 0)
            ->assertJsonPath('data.roles', 0);
    }
}
