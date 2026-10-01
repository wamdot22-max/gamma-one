<?php

namespace Tests\Feature\Fase3;

use App\Models\Enrollment;
use App\Models\Guardian;
use App\Models\NotificationLog;
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

class SessionChangeTest extends TestCase
{
    use RefreshDatabase;

    private User $tutorUser;

    private User $parentA;

    private User $parentB;

    private Session $session;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view', 'parents.view'] as $name) {
            Permission::firstOrCreate(['name' => $name, 'guard_name' => 'web']);
        }
        Role::firstOrCreate(['name' => 'tutor', 'guard_name' => 'web'])
            ->syncPermissions(['sessions.view', 'sessions.update', 'students.view', 'classes.view', 'enrollments.view']);
        Role::firstOrCreate(['name' => 'orang_tua', 'guard_name' => 'web'])
            ->syncPermissions(['students.view', 'parents.view', 'classes.view', 'enrollments.view', 'sessions.view']);

        $program = Program::factory()->create();
        $tutor = Tutor::factory()->create();
        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutor->id]);
        $studentA = Student::factory()->create(['name' => 'Anak A']);
        $studentB = Student::factory()->create(['name' => 'Anak B']);
        Enrollment::factory()->create(['student_id' => $studentA->id, 'school_class_id' => $class->id, 'status' => 'aktif']);
        Enrollment::factory()->create(['student_id' => $studentB->id, 'school_class_id' => $class->id, 'status' => 'aktif']);

        $guardianA = Guardian::factory()->create();
        $guardianA->students()->attach($studentA->id, ['relationship' => 'ayah']);
        $guardianB = Guardian::factory()->create();
        $guardianB->students()->attach($studentB->id, ['relationship' => 'ibu']);

        $this->parentA = User::factory()->create(['email' => 'pa@dev.local', 'password' => 'password123']);
        $this->parentA->syncRoles(['orang_tua']);
        $guardianA->update(['user_id' => $this->parentA->id]);
        $this->parentB = User::factory()->create(['email' => 'pb@dev.local', 'password' => 'password123']);
        $this->parentB->syncRoles(['orang_tua']);
        $guardianB->update(['user_id' => $this->parentB->id]);

        $this->tutorUser = User::factory()->create(['email' => 'tu@dev.local', 'password' => 'password123']);
        $this->tutorUser->syncRoles(['tutor']);
        $tutor->update(['user_id' => $this->tutorUser->id]);

        $this->session = Session::factory()->create([
            'school_class_id' => $class->id, 'tutor_id' => $tutor->id,
            'session_date' => '2026-10-05', 'start_time' => '08:00:00', 'end_time' => '09:30:00',
        ]);
    }

    public function test_reschedule_memperingatkan_ortu_yang_benar(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/reschedule", [
            'session_date' => '2026-10-07', 'start_time' => '10:00', 'end_time' => '11:30', 'reason' => 'Tutor berhalangan.',
        ])->assertOk();

        $logA = NotificationLog::where('user_id', $this->parentA->id)->where('template_key', 'jadwal_berubah')->first();
        $this->assertNotNull($logA);
        $this->assertStringContainsString('2026-10-07', $logA->body);
        $this->assertStringContainsString('Tutor berhalangan.', $logA->body);

        $logB = NotificationLog::where('user_id', $this->parentB->id)->where('template_key', 'jadwal_berubah')->first();
        $this->assertNotNull($logB);
        $this->assertStringContainsString('Anak B', $logB->body);
        $this->assertStringNotContainsString('Anak A', $logB->body);
    }

    public function test_batal_memperingatkan_ortu(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/cancel", [
            'reason' => 'Hujan deras.',
        ])->assertOk();

        $this->assertTrue(NotificationLog::where('user_id', $this->parentA->id)
            ->where('template_key', 'sesi_batal')->exists());
    }

    public function test_riwayat_terlihat_dan_terbatas(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/reschedule", [
            'session_date' => '2026-10-07', 'start_time' => '10:00', 'end_time' => '11:30', 'reason' => 'Acara.',
        ])->assertOk();

        $response = $this->actingAs($this->tutorUser, 'sanctum')->getJson("/api/v1/sessions/{$this->session->id}/history");
        $response->assertOk();
        $actions = collect($response->json('data'))->pluck('action')->all();
        $this->assertContains('updated', $actions);

        // Ortu sekelas boleh melihat; ortu kelas lain tidak.
        $this->actingAs($this->parentB, 'sanctum')->getJson("/api/v1/sessions/{$this->session->id}/history")
            ->assertOk();

        $program = Program::firstOrFail();
        $otherClass = SchoolClass::factory()->create(['program_id' => $program->id]);
        $otherStudent = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $otherStudent->id, 'school_class_id' => $otherClass->id, 'status' => 'aktif']);
        $guardianC = Guardian::factory()->create();
        $guardianC->students()->attach($otherStudent->id, ['relationship' => 'wali']);
        $parentC = User::factory()->create(['email' => 'pc@dev.local', 'password' => 'password123']);
        $parentC->syncRoles(['orang_tua']);
        $guardianC->update(['user_id' => $parentC->id]);

        $this->actingAs($parentC, 'sanctum')->getJson("/api/v1/sessions/{$this->session->id}/history")
            ->assertNotFound();
    }
}
