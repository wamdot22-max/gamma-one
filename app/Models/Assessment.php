<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Assessment extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    public const TYPES = ['ulangan', 'tryout', 'tugas'];

    protected $fillable = ['school_class_id', 'subject_id', 'title', 'type', 'assessment_date', 'max_score', 'weight'];

    protected function casts(): array
    {
        return ['assessment_date' => 'date', 'max_score' => 'decimal:2', 'weight' => 'decimal:2'];
    }

    public function schoolClass()
    {
        return $this->belongsTo(SchoolClass::class);
    }

    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }

    public function grades()
    {
        return $this->hasMany(Grade::class);
    }
}
