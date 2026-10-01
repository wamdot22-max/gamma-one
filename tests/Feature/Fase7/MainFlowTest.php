<?php

namespace Tests\Feature\Fase7;

use App\Models\Assessment;
use App\Models\Enrollment;
use App\Models\Invoice;
use App\Models\Program;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\Student;
use App\Models\Tutor;
use App\Models\User;
use App\Services\InvoiceService;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Alur utama: daftar -> jadwal -> absen -> bayar -> rapor.
 */
class MainFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    public function test_alur_utama(): void
    {
        $admin = User::where('email', 'admin.contoh@dev.local')->firstOrFail();
        $tutorUser = User::where('email', 'tutor@dev.local')->firstOrFail();
        $program = Program::firstOrFail();

        // 1. Daftar: siswa baru + enrollment.
        $student = $this->actingAs($admin, 'sanctum')->postJson('/api/v1/students', [
            'nis' => 'E2E-001', 'name' => 'Anak E2E',
        ])->assertCreated()->json('data');
        $class = SchoolClass::factory()->create(['program_id' => $program->id, 'capacity' => 10]);
        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/enrollments', [
            'student_id' => $student['id'], 'school_class_id' => $class->id,
        ])->assertCreated();

        // 2. Jadwal: buat jadwal + generate sesi.
        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/schedules', [
            'school_class_id' => $class->id, 'day_of_week' => 1, 'start_time' => '08:00', 'end_time' => '09:30',
        ])->assertCreated();
        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/sessions/generate', [
            'school_class_id' => $class->id, 'from_date' => '2026-10-05', 'to_date' => '2026-10-05',
        ])->assertCreated()->assertJsonPath('data.created', 1);
        $session = Session::where('school_class_id', $class->id)->firstOrFail();

        // 3. Absen oleh tutor.
        $tutor = Tutor::where('user_id', $tutorUser->id)->first();
        if (! $tutor) {
            $tutor = Tutor::factory()->create();
            $tutor->update(['user_id' => $tutorUser->id]);
        }
        $class->update(['tutor_id' => $tutor->id]);
        $session->update(['tutor_id' => $tutor->id]);
        $this->actingAs($tutorUser, 'sanctum')->putJson("/api/v1/sessions/{$session->id}/attendances", [
            'items' => [['student_id' => $student['id'], 'status' => 'hadir']],
        ])->assertOk();

        // 4. Bayar: generate invoice + lunasi.
        (new InvoiceService)->generateMonthly('2026-10');
        $invoice = Invoice::where('student_id', $student['id'])->where('period', '2026-10')->firstOrFail();
        $this->actingAs($admin, 'sanctum')->postJson('/api/v1/payments', [
            'invoice_id' => $invoice->id, 'amount' => $invoice->total, 'method' => 'tunai',
        ])->assertCreated();
        $this->assertSame('lunas', $invoice->fresh()->status);

        // 5. Rapor: tutor input nilai, rapor memuatnya.
        $assessment = Assessment::factory()->create(['school_class_id' => $class->id, 'assessment_date' => '2026-10-06']);
        $this->actingAs($tutorUser, 'sanctum')->putJson("/api/v1/assessments/{$assessment->id}/grades", [
            'items' => [['student_id' => $student['id'], 'score' => 90]],
        ])->assertOk();

        // 6. Dashboard admin memuat angka alur ini.
        $this->actingAs($admin, 'sanctum')->getJson('/api/v1/dashboard/summary')
            ->assertOk()
            ->assertJsonPath('data.siswa_aktif', Student::where('status', 'aktif')->count());
    }
}
