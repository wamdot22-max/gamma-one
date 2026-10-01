<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Subject extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['name', 'code', 'description'];

    public function tutors()
    {
        return $this->belongsToMany(Tutor::class, 'subject_tutor')->withTimestamps();
    }

    public function schoolClasses()
    {
        return $this->hasMany(SchoolClass::class);
    }
}
