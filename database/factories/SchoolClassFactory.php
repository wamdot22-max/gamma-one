<?php

namespace Database\Factories;

use App\Models\Program;
use App\Models\SchoolClass;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<SchoolClass>
 */
class SchoolClassFactory extends Factory
{
    protected $model = SchoolClass::class;

    public function definition(): array
    {
        return [
            'name' => 'Kelas '.fake()->unique()->words(2, true),
            'program_id' => Program::factory(),
            'capacity' => 20,
            'type' => 'reguler',
        ];
    }
}
