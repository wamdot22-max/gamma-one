<?php

namespace App\Models;

use App\Support\PhoneNumber;
use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Student extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['user_id', 'nis', 'name', 'gender', 'birth_date', 'phone', 'address', 'school', 'status'];

    protected function casts(): array
    {
        return ['birth_date' => 'date'];
    }

    protected function phone(): Attribute
    {
        return Attribute::make(set: fn ($value) => PhoneNumber::normalize($value));
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function guardians()
    {
        return $this->belongsToMany(Guardian::class, 'parent_student', 'student_id', 'parent_id')
            ->withPivot('relationship')->withTimestamps();
    }

    public function enrollments()
    {
        return $this->hasMany(Enrollment::class);
    }

    public function schoolClasses()
    {
        return $this->belongsToMany(SchoolClass::class, 'enrollments', 'student_id', 'school_class_id')
            ->withPivot('status')->withTimestamps();
    }
}
