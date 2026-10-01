<?php

namespace Database\Seeders;

use App\Models\Schedule;
use App\Models\SchoolClass;
use App\Models\Session;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

/**
 * Contoh jadwal mingguan + sesi minggu berjalan. Data fiktif.
 */
class SchedulingSampleSeeder extends Seeder
{
    public function run(): void
    {
        $defs = [
            ['class' => 'Matematika 7A', 'day' => 1, 'start' => '08:00', 'end' => '09:30'],
            ['class' => 'Matematika 7A', 'day' => 3, 'start' => '08:00', 'end' => '09:30'],
            ['class' => 'Fisika 8A', 'day' => 2, 'start' => '10:00', 'end' => '11:30'],
            ['class' => 'English 7B', 'day' => 4, 'start' => '13:00', 'end' => '14:30'],
        ];

        $schedules = collect();
        foreach ($defs as $def) {
            $class = SchoolClass::where('name', $def['class'])->first();
            if (! $class) {
                continue;
            }
            $schedules->push(Schedule::firstOrCreate(
                ['school_class_id' => $class->id, 'day_of_week' => $def['day'], 'start_time' => $def['start'].':00'],
                ['end_time' => $def['end'].':00', 'room_id' => $class->room_id, 'is_active' => true]
            ));
        }

        $monday = Carbon::now('Asia/Jakarta')->startOfWeek();
        foreach ($schedules as $schedule) {
            $date = $monday->copy()->addDays($schedule->day_of_week - 1);
            if ($date->isFuture()) {
                continue;
            }
            $class = $schedule->schoolClass;
            Session::firstOrCreate(
                ['school_class_id' => $schedule->school_class_id, 'session_date' => $date->toDateString(), 'start_time' => $schedule->start_time],
                [
                    'schedule_id' => $schedule->id, 'end_time' => $schedule->end_time,
                    'room_id' => $schedule->room_id ?? $class->room_id, 'tutor_id' => $class->tutor_id,
                    'status' => 'terjadwal',
                ]
            );
        }
    }
}
