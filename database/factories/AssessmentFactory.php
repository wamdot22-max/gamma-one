<?php

namespace Database\Factories;

use App\Models\Assessment;
use App\Models\SchoolClass;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Assessment>
 */
class AssessmentFactory extends Factory
{
    protected $model = Assessment::class;

    public function definition(): array
    {
        return [
            'school_class_id' => SchoolClass::factory(),
            'title' => 'Ulangan '.fake()->word(),
            'type' => 'ulangan',
            'assessment_date' => fake()->date(),
            'max_score' => 100,
            'weight' => 1,
        ];
    }
}
