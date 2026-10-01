<?php

namespace Tests\Feature\Fase3;

use App\Models\Enrollment;
use App\Models\Program;
use App\Models\Schedule;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\SessionSubstituteRequest;
use App\Models\Student;
use App\Models\Subject;
use App\Models\Tutor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class SubstituteTest extends TestCase
{
    use RefreshDatabase;

    private User $tutorA;

    private User $staf;

    private Session $session;

    private Tutor $tutorB;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view', 'payrolls.view', 'schedules.view'] as $name) {
            Permission::firstOrCreate(['name' => $name, 'guard_name' => 'web']);
        }
        Role::firstOrCreate(['name' => 'tutor', 'guard_name' => 'web'])
            ->syncPermissions(['sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view', 'schedules.view']);
        Role::firstOrCreate(['name' => 'staf', 'guard_name' => 'web'])
            ->syncPermissions(['sessions.view', 'sessions.update', 'payrolls.view']);

        $program = Program::factory()->create();
        $subject = Subject::factory()->create();
        $tutorA = Tutor::factory()->create(['fee_per_session' => 100000]);
        $tutorA->subjects()->attach($subject->id);
        $this->tutorB = Tutor::factory()->create(['fee_per_session' => 50000]);
        $this->tutorB->subjects()->attach($subject->id);

        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'subject_id' => $subject->id, 'tutor_id' => $tutorA->id]);
        $this->session = Session::factory()->create([
            'school_class_id' => $class->id, 'tutor_id' => $tutorA->id,
            'session_date' => '2026-10-05', 'start_time' => '08:00:00', 'end_time' => '09:30:00',
        ]);

        $this->tutorA = User::factory()->create(['email' => 'ta@dev.local', 'password' => 'password123']);
        $this->tutorA->syncRoles(['tutor']);
        $tutorA->update(['user_id' => $this->tutorA->id]);

        $this->staf = User::factory()->create(['email' => 'st@dev.local', 'password' => 'password123']);
        $this->staf->syncRoles(['staf']);
    }

    public function test_usul_lalu_disetujui_memasang_pengganti(): void
    {
        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$this->session->id}/substitute-requests", [
            'proposed_tutor_id' => $this->tutorB->id, 'reason' => 'Berhalangan.',
        ])->assertCreated();

        // Tutor tidak boleh menyetujui sendiri.
        $reqId = SessionSubstituteRequest::firstOrFail()->id;
        $this->actingAs($this->tutorA, 'sanctum')->putJson("/api/v1/substitute-requests/{$reqId}/approve", [])
            ->assertForbidden();

        $this->actingAs($this->staf, 'sanctum')->putJson("/api/v1/substitute-requests/{$reqId}/approve", [])
            ->assertOk();

        $this->assertSame($this->tutorB->id, $this->session->fresh()->substitute_tutor_id);

        // Honor hanya sesi selesai: tandai selesai dulu.
        $this->session->update(['status' => 'selesai']);

        // Honor ikut tarif tutor asli (100rb), diterima pengganti.
        $response = $this->actingAs($this->staf, 'sanctum')->getJson('/api/v1/payrolls?month=2026-10');
        $rows = collect($response->json('data.rows'));
        $rowB = $rows->firstWhere('tutor.id', $this->tutorB->id);
        $this->assertSame(1, $rowB['sessions_count']);
        $this->assertSame(100000, $rowB['total']);
        $rowA = $rows->firstWhere('tutor.id', $this->session->tutor_id);
        $this->assertSame(0, $rowA['sessions_count']);
    }

    public function test_usulan_ditolak_tidak_mengubah_sesi(): void
    {
        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$this->session->id}/substitute-requests", [
            'proposed_tutor_id' => $this->tutorB->id, 'reason' => 'Berhalangan.',
        ])->assertCreated();

        $reqId = SessionSubstituteRequest::firstOrFail()->id;
        $this->actingAs($this->staf, 'sanctum')->putJson("/api/v1/substitute-requests/{$reqId}/reject", ['review_note' => 'Cari yang lain.'])
            ->assertOk();

        $this->assertNull($this->session->fresh()->substitute_tutor_id);
    }

    public function test_kandidat_beda_mapel_dan_ganda_ditolak(): void
    {
        $otherSubject = Subject::factory()->create();
        $tutorC = Tutor::factory()->create();
        $tutorC->subjects()->attach($otherSubject->id);

        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$this->session->id}/substitute-requests", [
            'proposed_tutor_id' => $tutorC->id, 'reason' => 'X.',
        ])->assertStatus(422);

        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$this->session->id}/substitute-requests", [
            'proposed_tutor_id' => $this->tutorB->id, 'reason' => 'Y.',
        ])->assertCreated();

        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$this->session->id}/substitute-requests", [
            'proposed_tutor_id' => $this->tutorB->id, 'reason' => 'Z.',
        ])->assertStatus(422);
    }

    public function test_super_admin_dan_admin_bisa_menyetujui(): void
    {
        foreach (['super-admin' => '2026-10-08', 'admin' => '2026-10-09'] as $role => $date) {
            $session = Session::factory()->create([
                'school_class_id' => $this->session->school_class_id, 'tutor_id' => $this->session->tutor_id,
                'session_date' => $date, 'start_time' => '08:00:00', 'end_time' => '09:30:00',
            ]);
            $resp = $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$session->id}/substitute-requests", [
                'proposed_tutor_id' => $this->tutorB->id, 'reason' => 'Berhalangan.',
            ]);
            $resp->assertCreated();

            $approver = User::factory()->create(['password' => 'password123']);
            Role::firstOrCreate(['name' => $role, 'guard_name' => 'web']);
            $approver->syncRoles([$role]);
            if ($role !== 'super-admin') {
                $approver->givePermissionTo('sessions.view', 'sessions.update');
            } else {
                $approver->givePermissionTo(Permission::all());
            }

            $reqId = SessionSubstituteRequest::where('session_id', $session->id)->firstOrFail()->id;
            $this->actingAs($approver, 'sanctum')->putJson("/api/v1/substitute-requests/{$reqId}/approve", [])
                ->assertOk();

            $this->assertSame($this->tutorB->id, $session->fresh()->substitute_tutor_id);
        }
    }

    public function test_kandidat_bentrok_ditolak(): void
    {
        $program = Program::firstOrFail();
        $otherClass = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $this->tutorB->id]);
        Session::factory()->create([
            'school_class_id' => $otherClass->id, 'tutor_id' => $this->tutorB->id,
            'session_date' => '2026-10-05', 'start_time' => '08:30:00', 'end_time' => '10:00:00',
        ]);

        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$this->session->id}/substitute-requests", [
            'proposed_tutor_id' => $this->tutorB->id, 'reason' => 'Berhalangan.',
        ])->assertStatus(422);
    }

    public function test_tutor_melihat_opsi_pengganti_tanpa_izin_tutors(): void
    {
        // Peran tutor memang tidak punya tutors.view; endpoint khusus tetap bisa dipakai.
        $this->assertFalse($this->tutorA->getAllPermissions()->pluck('name')->contains('tutors.view'));

        $response = $this->actingAs($this->tutorA, 'sanctum')
            ->getJson("/api/v1/tutors/substitute-options?school_class_id={$this->session->school_class_id}");
        $response->assertOk();

        $names = collect($response->json('data'))->pluck('name')->all();
        $this->assertContains($this->tutorB->name, $names);
        $this->assertArrayNotHasKey('phone', $response->json('data')[0]);
    }

    public function test_pengganti_melihat_sesi_siswa_dan_bisa_absen(): void
    {
        $student = Student::factory()->create();
        Enrollment::factory()->create([
            'student_id' => $student->id, 'school_class_id' => $this->session->school_class_id, 'status' => 'aktif',
        ]);
        $userB = User::factory()->create(['password' => 'password123']);
        $userB->syncRoles(['tutor']);
        $this->tutorB->update(['user_id' => $userB->id]);

        // Sebelum disetujui: sesi tak terlihat.
        $this->actingAs($userB, 'sanctum')->getJson("/api/v1/sessions/{$this->session->id}")
            ->assertNotFound();

        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$this->session->id}/substitute-requests", [
            'proposed_tutor_id' => $this->tutorB->id, 'reason' => 'Berhalangan.',
        ])->assertCreated();
        $reqId = SessionSubstituteRequest::firstOrFail()->id;

        $staf = User::factory()->create(['password' => 'password123']);
        $staf->syncRoles(['staf']);
        $this->actingAs($staf, 'sanctum')->putJson("/api/v1/substitute-requests/{$reqId}/approve", [])->assertOk();

        // Sesudah disetujui: sesi, jadwal, siswa, absensi, dan filter terlihat.
        Schedule::factory()->create(['school_class_id' => $this->session->school_class_id, 'day_of_week' => 1]);
        $this->actingAs($userB, 'sanctum')->getJson("/api/v1/sessions/{$this->session->id}")->assertOk();
        // Jadwal yang tidak disubstitusikan ikut tersembunyi walau sekelas.
        $this->actingAs($userB, 'sanctum')->getJson('/api/v1/schedules')
            ->assertOk()->assertJsonPath('data.data', []);
        $this->actingAs($userB, 'sanctum')->getJson('/api/v1/students')
            ->assertOk()->assertJsonFragment(['nis' => $student->nis]);
        $this->actingAs($userB, 'sanctum')->getJson('/api/v1/sessions?digantikan=1')
            ->assertOk()->assertJsonFragment(['id' => $this->session->id]);
        $this->actingAs($userB, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $student->id, 'status' => 'hadir']],
        ])->assertOk();
    }

    public function test_jadwal_ditandai_utama_atau_pengganti(): void
    {
        $schedule = Schedule::factory()->create(['school_class_id' => $this->session->school_class_id, 'day_of_week' => 1]);
        $session = Session::factory()->create([
            'school_class_id' => $this->session->school_class_id, 'tutor_id' => $this->session->tutor_id,
            'schedule_id' => $schedule->id, 'session_date' => '2026-10-10',
            'start_time' => '08:00:00', 'end_time' => '09:30:00',
        ]);
        $this->actingAs($this->tutorA, 'sanctum')->postJson("/api/v1/sessions/{$session->id}/substitute-requests", [
            'proposed_tutor_id' => $this->tutorB->id, 'reason' => 'Berhalangan.',
        ])->assertCreated();
        $reqId = SessionSubstituteRequest::where('session_id', $session->id)->firstOrFail()->id;

        $staf = User::factory()->create(['password' => 'password123']);
        $staf->syncRoles(['staf']);
        $this->actingAs($staf, 'sanctum')->putJson("/api/v1/substitute-requests/{$reqId}/approve", [])->assertOk();

        $userB = User::factory()->create(['password' => 'password123']);
        $userB->syncRoles(['tutor']);
        $this->tutorB->update(['user_id' => $userB->id]);

        $response = $this->actingAs($userB, 'sanctum')->getJson('/api/v1/schedules');
        $response->assertOk();
        $this->assertSame('pengganti', collect($response->json('data.data'))->firstWhere('id', $schedule->id)['peran']);

        $filtered = $this->actingAs($userB, 'sanctum')->getJson('/api/v1/schedules?peran=pengganti');
        $filtered->assertOk();
        $this->assertNotEmpty($filtered->json('data.data'));
        foreach ($filtered->json('data.data') as $row) {
            $this->assertSame('pengganti', $row['peran']);
        }
    }
}
