<?php

namespace Database\Factories;

use App\Models\Session;
use App\Models\SessionSubstituteRequest;
use App\Models\Tutor;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<SessionSubstituteRequest>
 */
class SessionSubstituteRequestFactory extends Factory
{
    protected $model = SessionSubstituteRequest::class;

    public function definition(): array
    {
        return [
            'session_id' => Session::factory(),
            'proposed_tutor_id' => Tutor::factory(),
            'reason' => fake()->sentence(),
            'status' => 'diusulkan',
        ];
    }
}
