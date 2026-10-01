<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Assignment extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['school_class_id', 'title', 'description', 'deadline'];

    protected function casts(): array
    {
        return ['deadline' => 'datetime'];
    }

    public function schoolClass()
    {
        return $this->belongsTo(SchoolClass::class);
    }

    public function submissions()
    {
        return $this->hasMany(Submission::class);
    }
}
