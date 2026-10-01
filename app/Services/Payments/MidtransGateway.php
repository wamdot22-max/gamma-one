<?php

namespace App\Services\Payments;

use App\Models\GatewayTransaction;
use App\Models\Invoice;
use Midtrans\Config;
use Midtrans\Snap;

class MidtransGateway implements PaymentGateway
{
    public function __construct()
    {
        Config::$serverKey = (string) config('services.midtrans.server_key');
        Config::$clientKey = (string) config('services.midtrans.client_key');
        Config::$isProduction = (bool) config('services.midtrans.is_production', false);
        Config::$isSanitized = true;
        Config::$is3ds = true;
    }

    public function createCharge(Invoice $invoice): array
    {
        $invoice->loadMissing('student:id,name,phone');
        $orderId = $invoice->invoice_no.'-'.now()->format('His').'-'.$invoice->id;
        $gross = max(0, $invoice->total - $invoice->paid_amount);

        $params = [
            'transaction_details' => ['order_id' => $orderId, 'gross_amount' => $gross],
            'customer_details' => [
                'first_name' => $invoice->student->name ?? 'Wali Santri',
                'phone' => $invoice->student->phone ?? null,
            ],
            'item_details' => [[
                'id' => $invoice->invoice_no, 'price' => $gross, 'quantity' => 1,
                'name' => "Tagihan {$invoice->invoice_no}",
            ]],
        ];

        $token = Snap::getSnapToken($params);

        GatewayTransaction::create([
            'invoice_id' => $invoice->id, 'provider' => 'midtrans',
            'order_id' => $orderId, 'gross_amount' => $gross,
            'transaction_status' => 'pending', 'snap_token' => $token,
        ]);

        return ['order_id' => $orderId, 'token' => $token, 'gross_amount' => $gross];
    }

    public function verifyWebhook(array $payload): bool
    {
        $serverKey = (string) config('services.midtrans.server_key');
        $expected = hash('sha512', ($payload['order_id'] ?? '').($payload['status_code'] ?? '').($payload['gross_amount'] ?? '').$serverKey);

        return hash_equals($expected, (string) ($payload['signature_key'] ?? ''));
    }
}
