<?php

namespace Tests\Feature\Fase4;

use App\Models\Invoice;
use App\Models\Student;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaymentStatusTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private function staf(): User
    {
        return User::where('email', 'staf@dev.local')->firstOrFail();
    }

    private function invoice(int $total = 350000): Invoice
    {
        $student = Student::factory()->create();

        return Invoice::factory()->create(['student_id' => $student->id, 'total' => $total, 'due_date' => now()->addDays(7)->toDateString()]);
    }

    public function test_cicilan_sebagian_lalu_lunas(): void
    {
        $invoice = $this->invoice();

        $this->actingAs($this->staf(), 'sanctum')->postJson('/api/v1/payments', [
            'invoice_id' => $invoice->id, 'amount' => 150000, 'method' => 'tunai',
        ])->assertCreated();

        $this->assertSame('sebagian', $invoice->fresh()->status);

        $this->actingAs($this->staf(), 'sanctum')->postJson('/api/v1/payments', [
            'invoice_id' => $invoice->id, 'amount' => 200000, 'method' => 'transfer',
        ])->assertCreated();

        $this->assertSame('lunas', $invoice->fresh()->status);
        $this->assertSame(350000, $invoice->fresh()->paid_amount);
    }

    public function test_nominal_melebihi_sisa_ditolak(): void
    {
        $invoice = $this->invoice(100000);

        $this->actingAs($this->staf(), 'sanctum')->postJson('/api/v1/payments', [
            'invoice_id' => $invoice->id, 'amount' => 150000, 'method' => 'tunai',
        ])->assertStatus(422);
    }

    public function test_lewat_jatuh_tempo_jadi_terlambat(): void
    {
        $student = Student::factory()->create();
        $invoice = Invoice::factory()->create([
            'student_id' => $student->id, 'total' => 200000,
            'due_date' => now()->subDays(3)->toDateString(), 'status' => 'belum_bayar',
        ]);

        $this->actingAs($this->staf(), 'sanctum')->postJson('/api/v1/payments', [
            'invoice_id' => $invoice->id, 'amount' => 50000, 'method' => 'tunai',
        ])->assertCreated();

        $this->assertSame('terlambat', $invoice->fresh()->status);
    }

    public function test_kuitansi_pdf_dapat_diunduh(): void
    {
        $invoice = $this->invoice();

        $this->actingAs($this->staf(), 'sanctum')->getJson("/api/v1/invoices/{$invoice->id}/receipt")
            ->assertOk()
            ->assertHeader('content-type', 'application/pdf');
    }
}
