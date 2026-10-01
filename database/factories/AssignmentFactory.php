<?php

namespace Database\Factories;

use App\Models\Assignment;
use App\Models\SchoolClass;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Assignment>
 */
class AssignmentFactory extends Factory
{
    protected $model = Assignment::class;

    public function definition(): array
    {
        return [
            'school_class_id' => SchoolClass::factory(),
            'title' => 'Tugas '.fake()->words(2, true),
            'description' => fake()->sentence(),
            'deadline' => now()->addDays(7),
        ];
    }
}
