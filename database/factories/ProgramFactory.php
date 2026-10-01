<?php

namespace Database\Factories;

use App\Models\Program;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Program>
 */
class ProgramFactory extends Factory
{
    protected $model = Program::class;

    public function definition(): array
    {
        return [
            'name' => 'Program '.fake()->unique()->words(2, true),
            'description' => fake()->sentence(),
            'fee' => fake()->randomElement([250000, 350000, 500000]),
            'registration_fee' => 100000,
            'is_active' => true,
        ];
    }
}
