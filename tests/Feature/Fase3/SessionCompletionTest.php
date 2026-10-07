<?php

namespace Tests\Feature\Fase3;

use App\Models\Enrollment;
use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\Student;
use App\Models\Tutor;
use App\Models\User;
use App\Services\SessionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class SessionCompletionTest extends TestCase
{
    use RefreshDatabase;

    private User $tutorUser;

    private User $adminUser;

    private Session $session;

    private Student $student;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view'] as $name) {
            Permission::firstOrCreate(['name' => $name, 'guard_name' => 'web']);
        }
        Role::firstOrCreate(['name' => 'tutor', 'guard_name' => 'web'])
            ->syncPermissions(['sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view']);
        Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web'])
            ->syncPermissions(Permission::all());

        $program = Program::factory()->create();
        $tutor = Tutor::factory()->create();
        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutor->id]);
        $this->student = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $this->student->id, 'school_class_id' => $class->id, 'status' => 'aktif']);
        $this->session = Session::factory()->create([
            'school_class_id' => $class->id, 'tutor_id' => $tutor->id,
            'session_date' => '2026-10-05', 'start_time' => '08:00:00', 'end_time' => '09:30:00',
        ]);

        $this->tutorUser = User::factory()->create(['password' => 'password123']);
        $this->tutorUser->syncRoles(['tutor']);
        $tutor->update(['user_id' => $this->tutorUser->id]);
        $this->adminUser = User::factory()->create(['password' => 'password123']);
        $this->adminUser->syncRoles(['admin']);
    }

    public function test_selesai_butuh_absensi_penuh_lalu_terkunci(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')
            ->putJson("/api/v1/sessions/{$this->session->id}/complete", [])
            ->assertStatus(422);

        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->student->id, 'status' => 'hadir']],
            'material_notes' => 'Aljabar.',
        ])->assertOk();

        $this->actingAs($this->tutorUser, 'sanctum')
            ->putJson("/api/v1/sessions/{$this->session->id}/complete", [])
            ->assertOk()->assertJsonPath('data.status', 'selesai');

        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->student->id, 'status' => 'izin']],
        ])->assertStatus(422);

        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/reschedule", [
            'session_date' => '2026-10-06', 'start_time' => '08:00', 'end_time' => '09:30', 'reason' => 'X.',
        ])->assertStatus(422);
    }

    public function test_buka_ulang_hanya_admin(): void
    {
        $this->session->update(['status' => 'selesai']);

        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/reopen", ['reason' => 'Salah.'])
            ->assertForbidden();

        $this->actingAs($this->adminUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/reopen", ['reason' => 'Koreksi absensi.'])
            ->assertOk()->assertJsonPath('data.status', 'terjadwal');

        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->student->id, 'status' => 'hadir']],
        ])->assertOk();
    }

    public function test_auto_complete_hanya_yang_berabsensi(): void
    {
        $other = Session::factory()->create([
            'school_class_id' => $this->session->school_class_id, 'tutor_id' => $this->session->tutor_id,
            'session_date' => '2026-09-01', 'start_time' => '08:00:00', 'end_time' => '09:30:00',
        ]);
        $this->session->update(['session_date' => '2026-09-01']);
        $this->session->attendances()->create(['student_id' => $this->student->id, 'status' => 'hadir']);

        $done = (new SessionService)->autoCompletePastSessions();

        $this->assertSame(1, $done);
        $this->assertSame('selesai', $this->session->fresh()->status);
        $this->assertSame('terjadwal', $other->fresh()->status);
    }

    public function test_simpan_tanpa_tanda_ditolak(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->student->id]],
        ])->assertStatus(422);
    }

    public function test_selesai_butuh_catatan_materi(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->student->id, 'status' => 'hadir']],
        ])->assertOk();

        $this->actingAs($this->tutorUser, 'sanctum')
            ->putJson("/api/v1/sessions/{$this->session->id}/complete", [])
            ->assertStatus(422);

        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->student->id, 'status' => 'hadir']],
            'material_notes' => 'Aljabar dasar.',
        ])->assertOk();

        $this->actingAs($this->tutorUser, 'sanctum')
            ->putJson("/api/v1/sessions/{$this->session->id}/complete", [])
            ->assertOk();
    }

    public function test_tutor_otomatis_tercatat_hadir(): void
    {
        $this->assertNull($this->session->fresh()->tutor_status);

        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->student->id, 'status' => 'hadir']],
        ])->assertOk();

        $this->assertSame('hadir', $this->session->fresh()->tutor_status);
    }
}
