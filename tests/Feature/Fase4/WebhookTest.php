<?php

namespace Tests\Feature\Fase4;

use App\Models\GatewayTransaction;
use App\Models\Invoice;
use App\Models\Payment;
use App\Models\Student;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WebhookTest extends TestCase
{
    use RefreshDatabase;

    private string $serverKey = 'tes-server-key-abc';

    protected function setUp(): void
    {
        parent::setUp();
        config()->set('services.midtrans.server_key', $this->serverKey);
    }

    private function invoice(): Invoice
    {
        $student = Student::factory()->create();

        return Invoice::factory()->create(['student_id' => $student->id, 'total' => 350000]);
    }

    private function payload(Invoice $invoice, GatewayTransaction $trx, string $status = 'settlement'): array
    {
        $gross = '350000.00';
        $signature = hash('sha512', $trx->order_id.'200'.$gross.$this->serverKey);

        return [
            'order_id' => $trx->order_id, 'status_code' => '200', 'gross_amount' => $gross,
            'signature_key' => $signature, 'transaction_status' => $status, 'payment_type' => 'qris',
        ];
    }

    public function test_webhook_melunasi_invoice(): void
    {
        $invoice = $this->invoice();
        $trx = GatewayTransaction::create([
            'invoice_id' => $invoice->id, 'order_id' => 'ORD-1',
            'gross_amount' => 350000, 'transaction_status' => 'pending',
        ]);

        $this->postJson('/api/v1/webhooks/midtrans', $this->payload($invoice, $trx))->assertOk();

        $this->assertSame('lunas', $invoice->fresh()->status);
        $this->assertDatabaseHas('payments', ['reference' => 'ORD-1', 'method' => 'qris']);
    }

    public function test_webhook_ganda_tidak_diproses_dua_kali(): void
    {
        $invoice = $this->invoice();
        $trx = GatewayTransaction::create([
            'invoice_id' => $invoice->id, 'order_id' => 'ORD-2',
            'gross_amount' => 350000, 'transaction_status' => 'pending',
        ]);

        $this->postJson('/api/v1/webhooks/midtrans', $this->payload($invoice, $trx))->assertOk();
        $this->postJson('/api/v1/webhooks/midtrans', $this->payload($invoice, $trx))->assertOk()
            ->assertJsonPath('data', null);

        $this->assertSame(1, Payment::where('reference', 'ORD-2')->count());
        $this->assertSame(350000, $invoice->fresh()->paid_amount);
    }

    public function test_signature_palsu_ditolak(): void
    {
        $invoice = $this->invoice();
        $trx = GatewayTransaction::create([
            'invoice_id' => $invoice->id, 'order_id' => 'ORD-3',
            'gross_amount' => 350000, 'transaction_status' => 'pending',
        ]);

        $payload = $this->payload($invoice, $trx);
        $payload['signature_key'] = 'palsu';

        $this->postJson('/api/v1/webhooks/midtrans', $payload)->assertForbidden();

        $this->assertSame(0, Payment::where('reference', 'ORD-3')->count());
        $this->assertSame('belum_bayar', $invoice->fresh()->status);
    }
}
