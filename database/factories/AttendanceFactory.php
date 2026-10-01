<?php

namespace Database\Factories;

use App\Models\Attendance;
use App\Models\Session;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Attendance>
 */
class AttendanceFactory extends Factory
{
    protected $model = Attendance::class;

    public function definition(): array
    {
        return [
            'session_id' => Session::factory(),
            'student_id' => Student::factory(),
            'status' => 'hadir',
        ];
    }
}
