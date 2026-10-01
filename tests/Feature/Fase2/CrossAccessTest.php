<?php

namespace Tests\Feature\Fase2;

use App\Models\Enrollment;
use App\Models\Guardian;
use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Student;
use App\Models\Tutor;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class CrossAccessTest extends TestCase
{
    use RefreshDatabase;

    private User $parentA;

    private User $parentB;

    private User $tutorUser;

    private User $siswaUser;

    private Student $studentA;

    private Student $studentB;

    private SchoolClass $classA;

    private SchoolClass $classB;

    protected function setUp(): void
    {
        parent::setUp();

        foreach (['students.view', 'parents.view', 'classes.view', 'enrollments.view'] as $name) {
            Permission::firstOrCreate(['name' => $name, 'guard_name' => 'web']);
        }

        $ortu = Role::firstOrCreate(['name' => 'orang_tua', 'guard_name' => 'web']);
        $ortu->syncPermissions(['students.view', 'parents.view', 'classes.view', 'enrollments.view']);
        $tutorRole = Role::firstOrCreate(['name' => 'tutor', 'guard_name' => 'web']);
        $tutorRole->syncPermissions(['classes.view', 'students.view', 'enrollments.view']);
        $siswaRole = Role::firstOrCreate(['name' => 'siswa', 'guard_name' => 'web']);
        $siswaRole->syncPermissions(['students.view', 'classes.view', 'enrollments.view']);

        $program = Program::factory()->create();

        $this->studentA = Student::factory()->create(['nis' => 'CROSS-A']);
        $this->studentB = Student::factory()->create(['nis' => 'CROSS-B']);

        $guardianA = Guardian::factory()->create(['name' => 'Ortu A']);
        $guardianA->students()->attach($this->studentA->id, ['relationship' => 'ayah']);
        $guardianB = Guardian::factory()->create(['name' => 'Ortu B']);
        $guardianB->students()->attach($this->studentB->id, ['relationship' => 'ibu']);

        $tutorA = Tutor::factory()->create(['name' => 'Tutor A']);
        $tutorB = Tutor::factory()->create(['name' => 'Tutor B']);

        $this->classA = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutorA->id]);
        $this->classB = SchoolClass::factory()->create(['program_id' => $program->id, 'tutor_id' => $tutorB->id]);

        Enrollment::factory()->create(['student_id' => $this->studentA->id, 'school_class_id' => $this->classA->id, 'status' => 'aktif']);
        Enrollment::factory()->create(['student_id' => $this->studentB->id, 'school_class_id' => $this->classB->id, 'status' => 'aktif']);

        $this->parentA = $this->makeUser('ortu-a@dev.local', 'orang_tua');
        $guardianA->update(['user_id' => $this->parentA->id]);
        $this->parentB = $this->makeUser('ortu-b@dev.local', 'orang_tua');
        $guardianB->update(['user_id' => $this->parentB->id]);

        $this->tutorUser = $this->makeUser('tutor-a@dev.local', 'tutor');
        $tutorA->update(['user_id' => $this->tutorUser->id]);

        $this->siswaUser = $this->makeUser('siswa-a@dev.local', 'siswa');
        $this->studentA->update(['user_id' => $this->siswaUser->id]);
    }

    private function makeUser(string $email, string $role): User
    {
        $user = User::factory()->create(['email' => $email, 'password' => 'password123']);
        $user->syncRoles([$role]);

        return $user;
    }

    public function test_orang_tua_a_tidak_bisa_membuka_siswa_milik_b(): void
    {
        $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/students/{$this->studentB->id}")
            ->assertNotFound();

        $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/students/{$this->studentA->id}")
            ->assertOk();
    }

    public function test_orang_tua_hanya_melihat_anaknya_di_daftar(): void
    {
        $response = $this->actingAs($this->parentA, 'sanctum')->getJson('/api/v1/students');
        $response->assertOk();

        $ids = collect($response->json('data.data'))->pluck('id')->all();
        $this->assertSame([$this->studentA->id], $ids);
    }

    public function test_tutor_hanya_melihat_kelasnya(): void
    {
        $response = $this->actingAs($this->tutorUser, 'sanctum')->getJson('/api/v1/classes');
        $response->assertOk();

        $ids = collect($response->json('data.data'))->pluck('id')->all();
        $this->assertSame([$this->classA->id], $ids);

        $this->actingAs($this->tutorUser, 'sanctum')
            ->getJson("/api/v1/classes/{$this->classB->id}")
            ->assertNotFound();
    }

    public function test_siswa_hanya_melihat_dirinya(): void
    {
        $response = $this->actingAs($this->siswaUser, 'sanctum')->getJson('/api/v1/students');
        $response->assertOk();

        $ids = collect($response->json('data.data'))->pluck('id')->all();
        $this->assertSame([$this->studentA->id], $ids);
    }

    public function test_tutor_hanya_melihat_siswa_di_kelasnya(): void
    {
        $response = $this->actingAs($this->tutorUser, 'sanctum')->getJson('/api/v1/students');
        $response->assertOk();

        $ids = collect($response->json('data.data'))->pluck('id')->all();
        $this->assertSame([$this->studentA->id], $ids);

        $this->actingAs($this->tutorUser, 'sanctum')
            ->getJson("/api/v1/students/{$this->studentB->id}")
            ->assertNotFound();

        $this->actingAs($this->tutorUser, 'sanctum')
            ->getJson("/api/v1/students/{$this->studentA->id}")
            ->assertOk();
    }

    public function test_orang_tua_tidak_melihat_enrollment_anak_lain(): void
    {
        $response = $this->actingAs($this->parentA, 'sanctum')
            ->getJson("/api/v1/enrollments?student_id={$this->studentB->id}");
        $response->assertOk();
        $this->assertCount(0, $response->json('data.data'));
    }
}
