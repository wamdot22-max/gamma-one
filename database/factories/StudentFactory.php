<?php

namespace Database\Factories;

use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Student>
 */
class StudentFactory extends Factory
{
    protected $model = Student::class;

    public function definition(): array
    {
        return [
            'nis' => fake()->unique()->numerify('G1######'),
            'name' => fake()->name(),
            'gender' => fake()->randomElement(['L', 'P']),
            'birth_date' => fake()->date(),
            'phone' => '628'.fake()->unique()->numerify('##########'),
            'address' => fake()->address(),
            'school' => 'SMPN '.fake()->numberBetween(1, 30),
            'status' => 'aktif',
        ];
    }
}
