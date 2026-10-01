<?php

namespace Tests\Feature\Fase3;

use App\Models\Attendance;
use App\Models\Enrollment;
use App\Models\Guardian;
use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\Student;
use App\Models\Tutor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AttendanceAccessTest extends TestCase
{
    use RefreshDatabase;

    private User $tutorA;

    private User $parentA;

    private Session $sessionA;

    private Session $sessionB;

    private Student $studentA;

    private Student $studentB;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['schedules.view', 'sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view', 'parents.view'] as $name) {
            Permission::firstOrCreate(['name' => $name, 'guard_name' => 'web']);
        }
        $tutorRole = Role::firstOrCreate(['name' => 'tutor', 'guard_name' => 'web']);
        $tutorRole->syncPermissions(['schedules.view', 'sessions.view', 'sessions.update', 'classes.view', 'students.view', 'enrollments.view']);
        $ortu = Role::firstOrCreate(['name' => 'orang_tua', 'guard_name' => 'web']);
        $ortu->syncPermissions(['schedules.view', 'sessions.view', 'students.view', 'parents.view', 'classes.view', 'enrollments.view']);

        $program = Program::factory()->create();
        $this->studentA = Student::factory()->create(['nis' => 'ATT-A']);
        $this->studentB = Student::factory()->create(['nis' => 'ATT-B']);
        $tutorA = Tutor::factory()->create();
        $tutorB = Tutor::factory()->create();
        $classA = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutorA->id]);
        $classB = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutorB->id]);
        Enrollment::factory()->create(['student_id' => $this->studentA->id, 'school_class_id' => $classA->id, 'status' => 'aktif']);
        Enrollment::factory()->create(['student_id' => $this->studentB->id, 'school_class_id' => $classB->id, 'status' => 'aktif']);

        $this->sessionA = Session::factory()->create(['school_class_id' => $classA->id, 'tutor_id' => $tutorA->id, 'session_date' => '2026-10-05']);
        $this->sessionB = Session::factory()->create(['school_class_id' => $classB->id, 'tutor_id' => $tutorB->id, 'session_date' => '2026-10-05']);

        $this->tutorA = User::factory()->create(['email' => 'tutora@dev.local', 'password' => 'password123']);
        $this->tutorA->syncRoles(['tutor']);
        $tutorA->update(['user_id' => $this->tutorA->id]);

        $guardianA = Guardian::factory()->create();
        $guardianA->students()->attach($this->studentA->id, ['relationship' => 'ayah']);
        $this->parentA = User::factory()->create(['email' => 'ortua@dev.local', 'password' => 'password123']);
        $this->parentA->syncRoles(['orang_tua']);
        $guardianA->update(['user_id' => $this->parentA->id]);
    }

    public function test_tutor_menandai_absensi_siswa(): void
    {
        $response = $this->actingAs($this->tutorA, 'sanctum')->putJson("/api/v1/sessions/{$this->sessionA->id}/attendances", [
            'items' => [['student_id' => $this->studentA->id, 'status' => 'hadir']],
            'material_notes' => 'Aljabar dasar.',
            'tutor_status' => 'hadir',
        ]);
        $response->assertOk()->assertJsonPath('data.saved', 1);

        $this->assertDatabaseHas('attendances', ['session_id' => $this->sessionA->id, 'student_id' => $this->studentA->id, 'status' => 'hadir']);
        $this->assertSame('Aljabar dasar.', $this->sessionA->fresh()->material_notes);

        // Daftar absensi menunjukkan progres 1 dari 1.
        $this->actingAs($this->tutorA, 'sanctum')->getJson("/api/v1/sessions/{$this->sessionA->id}/attendances")
            ->assertOk()->assertJsonPath('data.filled', 1)->assertJsonPath('data.total', 1);
    }

    public function test_tutor_tidak_bisa_absen_sesi_kelas_lain(): void
    {
        $this->actingAs($this->tutorA, 'sanctum')->getJson("/api/v1/sessions/{$this->sessionB->id}/attendances")
            ->assertNotFound();

        $this->actingAs($this->tutorA, 'sanctum')->putJson("/api/v1/sessions/{$this->sessionB->id}/attendances", [
            'items' => [['student_id' => $this->studentB->id, 'status' => 'hadir']],
        ])->assertNotFound();
    }

    public function test_absen_siswa_luar_kelas_ditolak(): void
    {
        $this->actingAs($this->tutorA, 'sanctum')->putJson("/api/v1/sessions/{$this->sessionA->id}/attendances", [
            'items' => [['student_id' => $this->studentB->id, 'status' => 'hadir']],
        ])->assertStatus(422);
    }

    public function test_scan_qr_menandai_hadir(): void
    {
        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$this->sessionA->id}/attendances/scan", ['code' => 'ATT-A'])
            ->assertOk();

        $this->assertDatabaseHas('attendances', ['session_id' => $this->sessionA->id, 'student_id' => $this->studentA->id, 'status' => 'hadir']);
    }

    public function test_orang_tua_melihat_rekap_anaknya(): void
    {
        Attendance::factory()->create(['session_id' => $this->sessionA->id, 'student_id' => $this->studentA->id, 'status' => 'hadir']);

        $classId = $this->sessionA->school_class_id;
        $response = $this->actingAs($this->parentA, 'sanctum')->getJson("/api/v1/attendances/recap?school_class_id={$classId}");
        $response->assertOk();

        $rows = $response->json('data.rows');
        $this->assertCount(1, $rows);
        $this->assertSame('ATT-A', $rows[0]['student']['nis']);
        $this->assertSame(1, $rows[0]['hadir']);

        // Rekap kelas anak lain tidak terlihat (404 agar tak bocor keberadaannya).
        $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/attendances/recap?school_class_id={$this->sessionB->school_class_id}")
            ->assertNotFound();
    }
}
