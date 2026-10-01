<?php

namespace Database\Factories;

use App\Models\Invoice;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Invoice>
 */
class InvoiceFactory extends Factory
{
    protected $model = Invoice::class;

    public function definition(): array
    {
        $amount = 350000;

        return [
            'invoice_no' => 'INV/TEST/'.fake()->unique()->numerify('######'),
            'student_id' => Student::factory(),
            'issue_date' => fake()->date(),
            'due_date' => now()->addDays(7)->toDateString(),
            'amount' => $amount,
            'discount' => 0,
            'registration_fee' => 0,
            'total' => $amount,
            'paid_amount' => 0,
            'status' => 'belum_bayar',
            'source' => 'manual',
        ];
    }
}
