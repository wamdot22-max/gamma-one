<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GatewayTransaction extends Model
{
    use HasFactory;

    protected $fillable = ['invoice_id', 'provider', 'order_id', 'gross_amount', 'payment_type', 'transaction_status', 'snap_token', 'payload', 'paid_at'];

    protected function casts(): array
    {
        return ['gross_amount' => 'integer', 'payload' => 'array', 'paid_at' => 'datetime'];
    }

    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }
}
