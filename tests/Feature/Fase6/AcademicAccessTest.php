<?php

namespace Tests\Feature\Fase6;

use App\Models\Assessment;
use App\Models\Assignment;
use App\Models\Enrollment;
use App\Models\Guardian;
use App\Models\Material;
use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Student;
use App\Models\Tutor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AcademicAccessTest extends TestCase
{
    use RefreshDatabase;

    private User $tutorA;

    private User $tutorB;

    private User $parentA;

    private User $siswaA;

    private Student $studentA;

    private Student $studentB;

    private Assessment $assessmentA;

    private Material $materialB;

    private Assignment $assignmentA;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['assessments.view', 'assessments.create', 'grades.view', 'grades.update', 'materials.view', 'assignments.view', 'submissions.view', 'submissions.create', 'report-cards.view', 'students.view', 'classes.view', 'enrollments.view'] as $name) {
            Permission::firstOrCreate(['name' => $name, 'guard_name' => 'web']);
        }
        Role::firstOrCreate(['name' => 'tutor', 'guard_name' => 'web'])
            ->syncPermissions(['assessments.view', 'assessments.create', 'grades.view', 'grades.update', 'materials.view', 'report-cards.view', 'students.view', 'classes.view', 'enrollments.view']);
        Role::firstOrCreate(['name' => 'orang_tua', 'guard_name' => 'web'])
            ->syncPermissions(['grades.view', 'materials.view', 'assignments.view', 'submissions.view', 'report-cards.view', 'students.view', 'classes.view', 'enrollments.view']);
        Role::firstOrCreate(['name' => 'siswa', 'guard_name' => 'web'])
            ->syncPermissions(['grades.view', 'materials.view', 'assignments.view', 'submissions.view', 'submissions.create', 'report-cards.view', 'students.view']);

        $program = Program::factory()->create();
        $tutorA = Tutor::factory()->create();
        $tutorB = Tutor::factory()->create();
        $classA = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutorA->id]);
        $classB = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutorB->id]);

        $this->studentA = Student::factory()->create(['nis' => 'AKD-A']);
        $this->studentB = Student::factory()->create(['nis' => 'AKD-B']);
        Enrollment::factory()->create(['student_id' => $this->studentA->id, 'school_class_id' => $classA->id, 'status' => 'aktif']);
        Enrollment::factory()->create(['student_id' => $this->studentB->id, 'school_class_id' => $classB->id, 'status' => 'aktif']);

        $guardianA = Guardian::factory()->create();
        $guardianA->students()->attach($this->studentA->id, ['relationship' => 'ayah']);

        $this->assessmentA = Assessment::factory()->create(['school_class_id' => $classA->id, 'assessment_date' => '2026-10-05']);
        $this->materialB = Material::factory()->create(['school_class_id' => $classB->id, 'file_url' => '/rahasia.pdf']);
        $this->assignmentA = Assignment::factory()->create(['school_class_id' => $classA->id]);

        $this->tutorA = $this->makeUser('tutor-a@dev.local', 'tutor');
        $tutorA->update(['user_id' => $this->tutorA->id]);
        $this->tutorB = $this->makeUser('tutor-b@dev.local', 'tutor');
        $tutorB->update(['user_id' => $this->tutorB->id]);
        $this->parentA = $this->makeUser('ortu-a@dev.local', 'orang_tua');
        $guardianA->update(['user_id' => $this->parentA->id]);
        $this->siswaA = $this->makeUser('siswa-a@dev.local', 'siswa');
        $this->studentA->update(['user_id' => $this->siswaA->id]);
    }

    private function makeUser(string $email, string $role): User
    {
        $user = User::factory()->create(['email' => $email, 'password' => 'password123']);
        $user->syncRoles([$role]);

        return $user;
    }

    public function test_nilai_tutor_muncul_di_grafik_siswa(): void
    {
        $this->actingAs($this->tutorA, 'sanctum')->putJson("/api/v1/assessments/{$this->assessmentA->id}/grades", [
            'items' => [['student_id' => $this->studentA->id, 'score' => 88, 'note' => 'Bagus']],
        ])->assertOk();

        $response = $this->actingAs($this->siswaA, 'sanctum')
            ->getJson("/api/v1/grades/averages?student_id={$this->studentA->id}");
        $response->assertOk();

        $subjects = $response->json('data.subjects');
        $this->assertNotEmpty($subjects);
        $this->assertEquals(88, $subjects[0]['trend'][0]['score']);
    }

    public function test_tutor_tidak_bisa_menilai_kelas_lain(): void
    {
        $this->actingAs($this->tutorB, 'sanctum')
            ->getJson("/api/v1/assessments/{$this->assessmentA->id}/grades")
            ->assertNotFound();

        $this->actingAs($this->tutorB, 'sanctum')->putJson("/api/v1/assessments/{$this->assessmentA->id}/grades", [
            'items' => [['student_id' => $this->studentA->id, 'score' => 50]],
        ])->assertNotFound();
    }

    public function test_orang_tua_tidak_melihat_nilai_dan_materi_anak_lain(): void
    {
        $response = $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/grades?student_id={$this->studentB->id}");
        $response->assertOk();
        $this->assertCount(0, $response->json('data.data'));

        $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/materials/{$this->materialB->id}")
            ->assertNotFound();

        $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/report-cards/download?student_id={$this->studentB->id}")
            ->assertNotFound();
    }

    public function test_rapor_pdf_anak_sendiri_bisa_diunduh(): void
    {
        $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/report-cards/download?student_id={$this->studentA->id}")
            ->assertOk()
            ->assertHeader('content-type', 'application/pdf');
    }

    public function test_siswa_mengumpulkan_tugas_miliknya(): void
    {
        $this->actingAs($this->siswaA, 'sanctum')->postJson('/api/v1/submissions', [
            'assignment_id' => $this->assignmentA->id,
            'student_id' => $this->studentA->id,
            'file_url' => '/tugas-a.pdf',
        ])->assertCreated();

        $this->actingAs($this->siswaA, 'sanctum')->postJson('/api/v1/submissions', [
            'assignment_id' => $this->assignmentA->id,
            'student_id' => $this->studentB->id,
            'file_url' => '/tugas-palsu.pdf',
        ])->assertStatus(404);
    }
}
