<?php

namespace Database\Factories;

use App\Models\Material;
use App\Models\SchoolClass;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Material>
 */
class MaterialFactory extends Factory
{
    protected $model = Material::class;

    public function definition(): array
    {
        return [
            'school_class_id' => SchoolClass::factory(),
            'title' => 'Materi '.fake()->words(2, true),
            'description' => fake()->sentence(),
        ];
    }
}
