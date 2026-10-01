<?php

namespace App\Http\Controllers\Api\V1\Finance;

use App\Http\Controllers\Controller;
use App\Models\GatewayTransaction;
use App\Models\Payment;
use App\Services\InvoiceService;
use App\Services\NotificationService;
use App\Services\Payments\PaymentGateway;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class WebhookController extends Controller
{
    use ApiResponse;

    /**
     * Webhook Midtrans. Verifikasi signature dan idempoten: notifikasi yang
     * sama tidak diproses dua kali.
     */
    public function midtrans(Request $request, PaymentGateway $gateway, InvoiceService $service, NotificationService $notifications)
    {
        $payload = $request->all();

        if (! $gateway->verifyWebhook($payload)) {
            Log::warning('Webhook Midtrans signature palsu.', ['order_id' => $payload['order_id'] ?? null]);

            return $this->fail('Signature tidak valid.', 403);
        }

        $transaction = GatewayTransaction::where('order_id', $payload['order_id'] ?? '')->first();
        if (! $transaction) {
            return $this->fail('Transaksi tidak dikenal.', 404);
        }

        // Idempoten: yang sudah lunas/settlement tidak diproses ulang.
        if ($transaction->transaction_status === 'settlement') {
            return $this->ok(null, 'Sudah diproses.');
        }

        $status = $payload['transaction_status'] ?? 'pending';

        DB::transaction(function () use ($transaction, $payload, $status, $service, $notifications) {
            $transaction->update([
                'transaction_status' => $status,
                'payment_type' => $payload['payment_type'] ?? $transaction->payment_type,
                'payload' => $payload,
                'paid_at' => in_array($status, ['settlement', 'capture']) ? now() : null,
            ]);

            if (! in_array($status, ['settlement', 'capture'])) {
                return;
            }

            $method = ($payload['payment_type'] ?? '') === 'qris' ? 'qris' : 'va';
            Payment::firstOrCreate(['reference' => $transaction->order_id], [
                'invoice_id' => $transaction->invoice_id,
                'amount' => $transaction->gross_amount,
                'method' => $method,
                'paid_at' => now()->toDateString(),
                'notes' => 'Midtrans '.$status,
            ]);
            $invoice = $service->refreshStatus($transaction->invoice);

            $notifications->notifyParents(
                $invoice->student,
                'pembayaran_lunas',
                [
                    'nominal' => number_format($transaction->gross_amount, 0, ',', '.'),
                    'invoice' => $invoice->invoice_no,
                    'sisa' => number_format($invoice->total - $invoice->paid_amount, 0, ',', '.'),
                ],
                $invoice
            );
        });

        return $this->ok(null, 'Notifikasi diproses.');
    }
}
