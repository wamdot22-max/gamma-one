<?php

namespace Tests\Feature\Fase7;

use App\Models\Enrollment;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\Student;
use App\Models\Tutor;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TutorDashboardTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    public function test_tutor_melihat_ringkasannya(): void
    {
        $tutorUser = User::where('email', 'tutor@dev.local')->firstOrFail();
        $tutor = Tutor::where('user_id', $tutorUser->id)->first();
        if (! $tutor) {
            $tutor = Tutor::factory()->create();
            $tutor->update(['user_id' => $tutorUser->id]);
        }
        $class = SchoolClass::firstOrFail();
        $class->update(['tutor_id' => $tutor->id]);
        $student = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $class->id, 'status' => 'aktif']);
        Session::factory()->create([
            'school_class_id' => $class->id, 'tutor_id' => $tutor->id,
            'session_date' => now()->toDateString(), 'start_time' => '08:00:00', 'end_time' => '09:30:00',
        ]);

        $response = $this->actingAs($tutorUser, 'sanctum')->getJson('/api/v1/dashboard/summary');
        $response->assertOk();

        $data = $response->json('data');
        $this->assertGreaterThanOrEqual(1, $data['kelas_aktif']);
        $this->assertGreaterThanOrEqual(1, $data['total_siswa']);
        $this->assertGreaterThanOrEqual(1, $data['sesi_minggu_ini']);
        $this->assertNotEmpty($data['jadwal_hari_ini']);
        $this->assertSame(0, $data['users']);
        $this->assertNotEmpty($data['kehadiran_per_kelas']);
        $this->assertNotEmpty($data['rata_nilai_per_kelas']);
        $this->assertIsArray($data['usulan_pengganti']);
    }
}
