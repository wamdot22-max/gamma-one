<?php

namespace Database\Factories;

use App\Models\SchoolClass;
use App\Models\Session;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Session>
 */
class SessionFactory extends Factory
{
    protected $model = Session::class;

    public function definition(): array
    {
        return [
            'school_class_id' => SchoolClass::factory(),
            'session_date' => fake()->date(),
            'start_time' => '08:00:00',
            'end_time' => '09:30:00',
            'status' => 'terjadwal',
        ];
    }
}
