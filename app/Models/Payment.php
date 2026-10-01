<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Payment extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    public const METHODS = ['tunai', 'transfer', 'qris', 'va'];

    protected $fillable = ['invoice_id', 'amount', 'method', 'paid_at', 'proof_url', 'reference', 'notes'];

    protected function casts(): array
    {
        return ['paid_at' => 'date', 'amount' => 'integer'];
    }

    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }
}
