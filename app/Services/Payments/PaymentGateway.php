<?php

namespace App\Services\Payments;

use App\Models\Invoice;

interface PaymentGateway
{
    /**
     * @return array{order_id: string, token: ?string, gross_amount: int}
     */
    public function createCharge(Invoice $invoice): array;

    public function verifyWebhook(array $payload): bool;
}
