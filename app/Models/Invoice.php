<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Invoice extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    public const STATUSES = ['belum_bayar', 'sebagian', 'lunas', 'terlambat'];

    protected $fillable = ['invoice_no', 'student_id', 'enrollment_id', 'school_class_id', 'period', 'issue_date', 'due_date', 'amount', 'discount', 'registration_fee', 'total', 'paid_amount', 'status', 'source', 'notes'];

    protected function casts(): array
    {
        return [
            'issue_date' => 'date', 'due_date' => 'date',
            'amount' => 'integer', 'discount' => 'integer', 'registration_fee' => 'integer',
            'total' => 'integer', 'paid_amount' => 'integer',
        ];
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function enrollment()
    {
        return $this->belongsTo(Enrollment::class);
    }

    public function schoolClass()
    {
        return $this->belongsTo(SchoolClass::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    public function gatewayTransactions()
    {
        return $this->hasMany(GatewayTransaction::class);
    }

    public function getRemainingAttribute(): int
    {
        return max(0, $this->total - $this->paid_amount);
    }
}
