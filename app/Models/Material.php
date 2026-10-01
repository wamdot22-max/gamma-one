<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Material extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['school_class_id', 'title', 'description', 'file_url'];

    public function schoolClass()
    {
        return $this->belongsTo(SchoolClass::class);
    }
}
