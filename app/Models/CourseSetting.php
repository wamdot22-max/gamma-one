<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class CourseSetting extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['school_name', 'address', 'phone', 'email', 'academic_year', 'semester', 'invoice_due_days', 'description'];

    protected function casts(): array
    {
        return ['invoice_due_days' => 'integer'];
    }
}
