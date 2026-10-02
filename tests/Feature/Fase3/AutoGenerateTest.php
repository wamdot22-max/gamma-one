<?php

namespace Tests\Feature\Fase3;

use App\Models\CourseSetting;
use App\Models\Enrollment;
use App\Models\Program;
use App\Models\Schedule;
use App\Models\SchoolClass;
use App\Models\Session;
use App\Models\Student;
use App\Services\SessionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class AutoGenerateTest extends TestCase
{
    use RefreshDatabase;

    public function test_auto_generate_idempoten(): void
    {
        $program = Program::factory()->create();
        $class = SchoolClass::factory()->create(['program_id' => $program->id]);
        Schedule::factory()->create(['school_class_id' => $class->id, 'day_of_week' => 1, 'is_active' => true]);

        $service = new SessionService;
        $first = $service->autoGenerateUpcoming(2);
        $second = $service->autoGenerateUpcoming(2);

        $this->assertGreaterThan(0, $first['created']);
        $this->assertSame(0, $second['created']);
        $this->assertSame($first['created'], $second['skipped']);
    }

    public function test_jadwal_nonaktif_tidak_dibuatkan_sesi(): void
    {
        $program = Program::factory()->create();
        $class = SchoolClass::factory()->create(['program_id' => $program->id]);
        Schedule::factory()->create(['school_class_id' => $class->id, 'day_of_week' => 1, 'is_active' => false]);

        $result = (new SessionService)->autoGenerateUpcoming(2);

        $this->assertSame(0, $result['created']);
    }

    public function test_sesi_otomatis_bisa_diabsen(): void
    {
        $program = Program::factory()->create();
        $class = SchoolClass::factory()->create(['program_id' => $program->id]);
        $todayDow = (int) now()->dayOfWeekIso;
        Schedule::factory()->create(['school_class_id' => $class->id, 'day_of_week' => $todayDow, 'is_active' => true]);
        $student = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $class->id, 'status' => 'aktif']);

        (new SessionService)->autoGenerateUpcoming(1);

        $session = Session::where('school_class_id', $class->id)->whereDate('session_date', now()->toDateString())->first();
        $this->assertNotNull($session);
        $this->assertSame('terjadwal', $session->status);
    }

    public function test_keputusan_frekuensi(): void
    {
        $service = new SessionService;
        $monday = Carbon::parse('2026-10-05 07:00');

        $off = new CourseSetting(['auto_generate_enabled' => false]);
        $this->assertFalse($service->shouldAutoGenerateToday($off, $monday));
        $this->assertFalse($service->shouldAutoGenerateToday(null, $monday));

        $daily = new CourseSetting(['auto_generate_enabled' => true, 'auto_generate_frequency' => 'harian', 'auto_generate_time' => '06:00']);
        $this->assertTrue($service->shouldAutoGenerateToday($daily, $monday));

        $early = new CourseSetting(['auto_generate_enabled' => true, 'auto_generate_frequency' => 'harian', 'auto_generate_time' => '08:00']);
        $this->assertFalse($service->shouldAutoGenerateToday($early, $monday));

        $weeklyHit = new CourseSetting(['auto_generate_enabled' => true, 'auto_generate_frequency' => 'mingguan', 'auto_generate_time' => '06:00', 'auto_generate_day' => 1]);
        $this->assertTrue($service->shouldAutoGenerateToday($weeklyHit, $monday));
        $weeklyMiss = new CourseSetting(['auto_generate_enabled' => true, 'auto_generate_frequency' => 'mingguan', 'auto_generate_time' => '06:00', 'auto_generate_day' => 2]);
        $this->assertFalse($service->shouldAutoGenerateToday($weeklyMiss, $monday));

        $monthlyHit = new CourseSetting(['auto_generate_enabled' => true, 'auto_generate_frequency' => 'bulanan', 'auto_generate_time' => '06:00', 'auto_generate_day' => 5]);
        $this->assertTrue($service->shouldAutoGenerateToday($monthlyHit, $monday));
        $this->assertFalse($service->shouldAutoGenerateToday($monthlyHit, Carbon::parse('2026-10-06 07:00')));
    }
}
