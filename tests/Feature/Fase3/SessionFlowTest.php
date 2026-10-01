<?php

namespace Tests\Feature\Fase3;

use App\Models\Program;
use App\Models\Schedule;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\Tutor;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SessionFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private function admin(): User
    {
        return User::where('email', 'admin.contoh@dev.local')->firstOrFail();
    }

    public function test_generate_idempoten(): void
    {
        $program = Program::firstOrFail();
        $class = SchoolClass::factory()->create(['program_id' => $program->id]);
        Schedule::factory()->create(['school_class_id' => $class->id, 'day_of_week' => 1, 'start_time' => '08:00:00', 'end_time' => '09:30:00']);

        $payload = ['school_class_id' => $class->id, 'from_date' => '2026-10-05', 'to_date' => '2026-10-12'];

        $this->actingAs($this->admin(), 'sanctum')->postJson('/api/v1/sessions/generate', $payload)
            ->assertCreated()->assertJsonPath('data.created', 2);

        $this->actingAs($this->admin(), 'sanctum')->postJson('/api/v1/sessions/generate', $payload)
            ->assertCreated()->assertJsonPath('data.created', 0)
            ->assertJsonPath('data.skipped', 2);
    }

    public function test_simpan_jadwal_bentrok_ditolak(): void
    {
        $tutor = Tutor::factory()->create();
        $program = Program::firstOrFail();
        $a = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutor->id]);
        $b = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutor->id]);
        Schedule::factory()->create(['school_class_id' => $a->id, 'day_of_week' => 1, 'start_time' => '08:00:00', 'end_time' => '09:30:00']);

        $this->actingAs($this->admin(), 'sanctum')->postJson('/api/v1/schedules', [
            'school_class_id' => $b->id, 'day_of_week' => 1, 'start_time' => '09:00', 'end_time' => '10:30',
        ])->assertStatus(422)->assertJsonPath('success', false);
    }

    public function test_reschedule_bentrok_ditolak_tanpa_alasan_ditolak(): void
    {
        $tutor = Tutor::factory()->create();
        $program = Program::firstOrFail();
        $a = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutor->id]);
        $b = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutor->id]);
        Schedule::factory()->create(['school_class_id' => $a->id, 'day_of_week' => 1, 'start_time' => '08:00:00', 'end_time' => '09:30:00']);
        $session = Session::factory()->create(['school_class_id' => $b->id, 'tutor_id' => $tutor->id, 'session_date' => '2026-10-05', 'start_time' => '13:00:00', 'end_time' => '14:30:00']);

        // Tanpa alasan.
        $this->actingAs($this->admin(), 'sanctum')->putJson("/api/v1/sessions/{$session->id}/reschedule", [
            'session_date' => '2026-10-05', 'start_time' => '15:00', 'end_time' => '16:30',
        ])->assertStatus(422);

        // Bentrok tutor.
        $this->actingAs($this->admin(), 'sanctum')->putJson("/api/v1/sessions/{$session->id}/reschedule", [
            'session_date' => '2026-10-05', 'start_time' => '08:30', 'end_time' => '10:00', 'reason' => 'Ruangan dipakai acara.',
        ])->assertStatus(422);

        // Reschedule bersih berhasil.
        $this->actingAs($this->admin(), 'sanctum')->putJson("/api/v1/sessions/{$session->id}/reschedule", [
            'session_date' => '2026-10-06', 'start_time' => '08:00', 'end_time' => '09:30', 'reason' => 'Hari libur.',
        ])->assertOk();

        // Batal tanpa alasan ditolak, dengan alasan berhasil.
        $this->actingAs($this->admin(), 'sanctum')->putJson("/api/v1/sessions/{$session->id}/cancel", [])
            ->assertStatus(422);
        $this->actingAs($this->admin(), 'sanctum')->putJson("/api/v1/sessions/{$session->id}/cancel", ['reason' => 'Tutor sakit.'])
            ->assertOk()->assertJsonPath('data.status', 'dibatalkan');
    }
}
