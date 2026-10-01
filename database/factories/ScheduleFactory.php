<?php

namespace Database\Factories;

use App\Models\Schedule;
use App\Models\SchoolClass;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Schedule>
 */
class ScheduleFactory extends Factory
{
    protected $model = Schedule::class;

    public function definition(): array
    {
        return [
            'school_class_id' => SchoolClass::factory(),
            'day_of_week' => fake()->numberBetween(1, 6),
            'start_time' => '08:00:00',
            'end_time' => '09:30:00',
            'is_active' => true,
        ];
    }
}
