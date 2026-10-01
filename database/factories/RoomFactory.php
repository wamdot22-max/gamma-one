<?php

namespace Database\Factories;

use App\Models\Room;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Room>
 */
class RoomFactory extends Factory
{
    protected $model = Room::class;

    public function definition(): array
    {
        return [
            'name' => 'Ruang '.fake()->unique()->bothify('#?'),
            'capacity' => fake()->randomElement([10, 15, 20]),
            'location' => 'Lantai '.fake()->numberBetween(1, 3),
        ];
    }
}
