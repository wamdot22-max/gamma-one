<?php

namespace Tests\Feature\Fase4;

use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\Tutor;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PayrollTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    public function test_honor_dihitung_dari_jumlah_sesi(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();
        $tutor = Tutor::factory()->create(['fee_per_session' => 100000]);
        $program = Program::firstOrFail();
        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutor->id]);

        Session::factory()->count(3)->create(['school_class_id' => $class->id, 'tutor_id' => $tutor->id, 'session_date' => '2026-10-05', 'status' => 'selesai']);
        Session::factory()->create(['school_class_id' => $class->id, 'tutor_id' => $tutor->id, 'session_date' => '2026-10-06', 'status' => 'dibatalkan']);

        $response = $this->actingAs($admin, 'sanctum')->getJson('/api/v1/payrolls?month=2026-10');
        $response->assertOk();

        $row = collect($response->json('data.rows'))->firstWhere('tutor.id', $tutor->id);
        $this->assertSame(3, $row['sessions_count']);
        $this->assertSame(300000, $row['total']);
    }

    public function test_tutor_hanya_melihat_slip_sendiri(): void
    {
        $tutorA = Tutor::factory()->create();
        $tutorB = Tutor::factory()->create();
        $userA = User::factory()->create(['password' => 'password123']);
        $userA->syncRoles(['tutor']);
        $tutorA->update(['user_id' => $userA->id]);

        $response = $this->actingAs($userA, 'sanctum')->getJson('/api/v1/payrolls?month=2026-10');
        $response->assertOk();
        $ids = collect($response->json('data.rows'))->pluck('tutor.id')->all();
        $this->assertSame([$tutorA->id], $ids);

        $this->actingAs($userA, 'sanctum')->getJson("/api/v1/payrolls/{$tutorB->id}/slip?month=2026-10")
            ->assertNotFound();
    }
}
