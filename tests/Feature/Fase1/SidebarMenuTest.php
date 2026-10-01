<?php

namespace Tests\Feature\Fase1;

use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SidebarMenuTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private function sidebar(User $user): array
    {
        $response = $this->actingAs($user, 'sanctum')->getJson('/api/v1/menus/sidebar');
        $response->assertOk();

        return $response->json('data');
    }

    private function flattenPaths(array $nodes): array
    {
        $paths = [];
        $collect = function (array $nodes) use (&$collect, &$paths): void {
            foreach ($nodes as $node) {
                if (! empty($node['path'])) {
                    $paths[] = $node['path'];
                }
                if (! empty($node['children'])) {
                    $collect($node['children']);
                }
            }
        };
        $collect($nodes);

        return $paths;
    }

    public function test_super_admin_melihat_semua_menu(): void
    {
        $paths = $this->flattenPaths($this->sidebar(User::where('email', 'admin@dev.local')->firstOrFail()));

        $this->assertContains('/dashboard', $paths);
        $this->assertContains('/users', $paths);
        $this->assertContains('/blamable-logs', $paths);
        $this->assertContains('/students', $paths);
        $this->assertContains('/classes', $paths);
        $this->assertContains('/enrollments', $paths);
    }

    public function test_staf_tidak_melihat_audit_log(): void
    {
        $tree = $this->sidebar(User::where('email', 'staf@dev.local')->firstOrFail());
        $paths = $this->flattenPaths($tree);

        $this->assertContains('/dashboard', $paths);
        $this->assertContains('/users', $paths);
        $this->assertContains('/students', $paths);
        $this->assertNotContains('/blamable-logs', $paths);
        // Menu level atas (Dashboard, Pengaturan, Data Master) maksimal 7.
        $this->assertLessThanOrEqual(7, count($tree));
    }

    public function test_siswa_hanya_melihat_dashboard(): void
    {
        // Siswa memakai navigasi portal; sidebar API tidak menampilkan Data Master.
        $paths = $this->flattenPaths($this->sidebar(User::where('email', 'siswa@dev.local')->firstOrFail()));

        $this->assertSame(['/dashboard'], $paths);
    }

    public function test_orang_tua_hanya_melihat_dashboard(): void
    {
        // Orang tua memakai navigasi portal; sidebar API tidak menampilkan Data Master.
        $paths = $this->flattenPaths($this->sidebar(User::where('email', 'orangtua@dev.local')->firstOrFail()));

        $this->assertSame(['/dashboard'], $paths);
    }

    public function test_tutor_hanya_melihat_dashboard(): void
    {
        // Menu mengajar (Jadwal, Sesi & Absensi) tampil untuk tutor; Data Master tidak.
        $paths = $this->flattenPaths($this->sidebar(User::where('email', 'tutor@dev.local')->firstOrFail()));

        $this->assertContains('/dashboard', $paths);
        $this->assertContains('/schedules', $paths);
        $this->assertContains('/sessions', $paths);
        $this->assertNotContains('/users', $paths);
        $this->assertNotContains('/students', $paths);
        $this->assertNotContains('/classes', $paths);
    }
}
