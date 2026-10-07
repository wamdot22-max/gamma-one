<?php

namespace Tests\Feature\Fase3;

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

class JournalTest extends TestCase
{
    use RefreshDatabase;

    private User $tutorUser;

    private User $parentA;

    private User $parentB;

    private Session $session;

    private Student $studentA;

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
        $this->studentA = Student::factory()->create(['name' => 'Anak A']);
        $studentB = Student::factory()->create(['name' => 'Anak B']);
        Enrollment::factory()->create(['student_id' => $this->studentA->id, 'school_class_id' => $class->id, 'status' => 'aktif']);
        Enrollment::factory()->create(['student_id' => $studentB->id, 'school_class_id' => $class->id, 'status' => 'aktif']);

        $guardianA = Guardian::factory()->create();
        $guardianA->students()->attach($this->studentA->id, ['relationship' => 'ayah']);
        $guardianB = Guardian::factory()->create();
        $guardianB->students()->attach($studentB->id, ['relationship' => 'ibu']);

        $this->parentA = User::factory()->create(['password' => 'password123']);
        $this->parentA->syncRoles(['orang_tua']);
        $guardianA->update(['user_id' => $this->parentA->id]);
        $this->parentB = User::factory()->create(['password' => 'password123']);
        $this->parentB->syncRoles(['orang_tua']);
        $guardianB->update(['user_id' => $this->parentB->id]);

        $this->tutorUser = User::factory()->create(['password' => 'password123']);
        $this->tutorUser->syncRoles(['tutor']);
        $tutor->update(['user_id' => $this->tutorUser->id]);

        $this->session = Session::factory()->create(['school_class_id' => $class->id, 'tutor_id' => $tutor->id]);
    }

    public function test_jurnal_terlihat_ortu_yang_benar(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->studentA->id, 'status' => 'hadir', 'understanding' => 4, 'note' => 'Mulai paham pecahan.']],
        ])->assertOk();

        $response = $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/journals?student_id={$this->studentA->id}");
        $response->assertOk();

        $entries = $response->json('data.data');
        $this->assertNotEmpty($entries);
        $this->assertSame(4, $entries[0]['pemahaman']);
        $this->assertSame('Mulai paham pecahan.', $entries[0]['catatan']);

        $other = $this->actingAs($this->parentB, 'sanctum')
            ->getJson("/api/v1/journals?student_id={$this->studentA->id}");
        $other->assertNotFound();
    }

    public function test_validasi_bintang(): void
    {
        $this->actingAs($this->tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$this->session->id}/attendances", [
            'items' => [['student_id' => $this->studentA->id, 'status' => 'hadir', 'understanding' => 9]],
        ])->assertStatus(422);
    }
}
