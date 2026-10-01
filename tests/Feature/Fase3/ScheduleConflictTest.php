<?php

namespace Tests\Feature\Fase3;

use App\Models\Enrollment;
use App\Models\Program;
use App\Models\Room;
use App\Models\Schedule;
use App\Models\SchoolClass;
use App\Models\Student;
use App\Models\Tutor;
use App\Services\ScheduleConflictService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ScheduleConflictTest extends TestCase
{
    use RefreshDatabase;

    private ScheduleConflictService $service;

    private Program $program;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new ScheduleConflictService;
        $this->program = Program::factory()->create();
    }

    private function makeClass(?Tutor $tutor = null, ?Room $room = null): SchoolClass
    {
        return SchoolClass::factory()->create([
            'program_id' => $this->program->id,
            'tutor_id' => $tutor?->id,
            'room_id' => $room?->id,
        ]);
    }

    public function test_bentrok_tutor_terdeteksi(): void
    {
        $tutor = Tutor::factory()->create();
        $a = $this->makeClass($tutor);
        $b = $this->makeClass($tutor);
        Schedule::factory()->create(['school_class_id' => $a->id, 'day_of_week' => 1, 'start_time' => '08:00:00', 'end_time' => '09:30:00']);

        $conflicts = $this->service->checkSchedule([
            'school_class_id' => $b->id, 'day_of_week' => 1, 'start_time' => '09:00:00', 'end_time' => '10:30:00',
        ]);

        $this->assertNotEmpty(array_filter($conflicts, fn ($c) => $c['type'] === 'tutor'));
    }

    public function test_bentrok_ruangan_terdeteksi(): void
    {
        $room = Room::factory()->create();
        $a = $this->makeClass(null, $room);
        $b = $this->makeClass(null, $room);
        Schedule::factory()->create(['school_class_id' => $a->id, 'day_of_week' => 2, 'start_time' => '08:00:00', 'end_time' => '09:30:00']);

        $conflicts = $this->service->checkSchedule([
            'school_class_id' => $b->id, 'day_of_week' => 2, 'start_time' => '08:30:00', 'end_time' => '10:00:00', 'room_id' => $room->id,
        ]);

        $this->assertNotEmpty(array_filter($conflicts, fn ($c) => $c['type'] === 'ruangan'));
    }

    public function test_bentrok_siswa_terdeteksi(): void
    {
        $a = $this->makeClass();
        $b = $this->makeClass();
        $student = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $a->id, 'status' => 'aktif']);
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $b->id, 'status' => 'aktif']);
        Schedule::factory()->create(['school_class_id' => $a->id, 'day_of_week' => 3, 'start_time' => '08:00:00', 'end_time' => '09:30:00']);

        $conflicts = $this->service->checkSchedule([
            'school_class_id' => $b->id, 'day_of_week' => 3, 'start_time' => '08:30:00', 'end_time' => '10:00:00',
        ]);

        $this->assertNotEmpty(array_filter($conflicts, fn ($c) => $c['type'] === 'siswa'));
    }

    public function test_jam_bersambung_tidak_bentrok(): void
    {
        $tutor = Tutor::factory()->create();
        $room = Room::factory()->create();
        $a = $this->makeClass($tutor, $room);
        $b = $this->makeClass($tutor, $room);
        $student = Student::factory()->create();
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $a->id, 'status' => 'aktif']);
        Enrollment::factory()->create(['student_id' => $student->id, 'school_class_id' => $b->id, 'status' => 'aktif']);
        Schedule::factory()->create(['school_class_id' => $a->id, 'day_of_week' => 4, 'start_time' => '08:00:00', 'end_time' => '09:00:00']);

        $conflicts = $this->service->checkSchedule([
            'school_class_id' => $b->id, 'day_of_week' => 4, 'start_time' => '09:00:00', 'end_time' => '10:30:00', 'room_id' => $room->id,
        ]);

        $this->assertSame([], $conflicts);
    }

    public function test_hari_berbeda_tidak_bentrok(): void
    {
        $tutor = Tutor::factory()->create();
        $a = $this->makeClass($tutor);
        $b = $this->makeClass($tutor);
        Schedule::factory()->create(['school_class_id' => $a->id, 'day_of_week' => 1, 'start_time' => '08:00:00', 'end_time' => '09:30:00']);

        $conflicts = $this->service->checkSchedule([
            'school_class_id' => $b->id, 'day_of_week' => 2, 'start_time' => '08:00:00', 'end_time' => '09:30:00',
        ]);

        $this->assertSame([], $conflicts);
    }

    public function test_update_mengabaikan_jadwal_sendiri(): void
    {
        $a = $this->makeClass();
        $schedule = Schedule::factory()->create(['school_class_id' => $a->id, 'day_of_week' => 5, 'start_time' => '08:00:00', 'end_time' => '09:30:00']);

        $conflicts = $this->service->checkSchedule([
            'school_class_id' => $a->id, 'day_of_week' => 5, 'start_time' => '08:00:00', 'end_time' => '09:30:00',
        ], $schedule->id);

        $this->assertSame([], $conflicts);
    }
}
