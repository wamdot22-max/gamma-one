<?php

namespace Tests\Feature\Fase2;

use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CapacityTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    public function test_enrollment_ditolak_bila_kelas_penuh(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();
        $program = Program::firstOrFail();
        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'capacity' => 2]);
        $students = Student::factory()->count(3)->create();

        foreach ([0, 1] as $i) {
            $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
                'student_id' => $students[$i]->id, 'school_class_id' => $class->id,
            ])->assertCreated();
        }

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $students[2]->id, 'school_class_id' => $class->id,
        ])->assertStatus(422)->assertJsonPath('success', false);
    }

    public function test_pindah_ke_kelas_penuh_ditolak(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();
        $program = Program::firstOrFail();
        $penuh = SchoolClass::factory()->create(['program_id' => $program->id, 'capacity' => 1]);
        $longgar = SchoolClass::factory()->create(['program_id' => $program->id, 'capacity' => 10]);
        $students = Student::factory()->count(2)->create();

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $students[0]->id, 'school_class_id' => $penuh->id,
        ])->assertCreated();

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $students[1]->id, 'school_class_id' => $longgar->id,
        ])->assertCreated();
        $enrollmentId = $response->json('data.id');

        $this->actingAs($admin, 'sanctum')->putJson("/api/v1/enrollments/{$enrollmentId}", [
            'student_id' => $students[1]->id, 'school_class_id' => $penuh->id,
        ])->assertStatus(422)->assertJsonPath('success', false);
    }

    public function test_daftar_ulang_setelah_dihapus_memulihkan(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();
        $program = Program::firstOrFail();
        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'capacity' => 10]);
        $student = Student::factory()->create();

        $response = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $student->id, 'school_class_id' => $class->id,
        ])->assertCreated();
        $enrollmentId = $response->json('data.id');

        $this->actingAs($admin, 'sanctum')->deleteJson("/api/v1/enrollments/{$enrollmentId}")->assertOk();

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $student->id, 'school_class_id' => $class->id,
        ])->assertCreated()->assertJsonPath('data.id', $enrollmentId);
    }

    public function test_enrollment_ganda_ditolak(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();
        $program = Program::firstOrFail();
        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'capacity' => 10]);
        $student = Student::factory()->create();

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $student->id, 'school_class_id' => $class->id,
        ])->assertCreated();

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $student->id, 'school_class_id' => $class->id,
        ])->assertStatus(422);
    }

    public function test_status_nonaktif_tidak_menghitung_kapasitas(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();
        $program = Program::firstOrFail();
        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'capacity' => 1]);
        $students = Student::factory()->count(2)->create();

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $students[0]->id, 'school_class_id' => $class->id, 'status' => 'selesai',
        ])->assertCreated();

        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $students[1]->id, 'school_class_id' => $class->id,
        ])->assertCreated();
    }
}
