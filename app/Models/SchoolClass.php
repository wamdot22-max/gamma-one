<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SchoolClass extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['name', 'program_id', 'subject_id', 'tutor_id', 'room_id', 'capacity', 'type', 'description'];

    protected function casts(): array
    {
        return ['capacity' => 'integer'];
    }

    public function program()
    {
        return $this->belongsTo(Program::class);
    }

    public function subject()
    {
        return $this->belongsTo(Subject::class);
    }

    public function tutor()
    {
        return $this->belongsTo(Tutor::class);
    }

    public function room()
    {
        return $this->belongsTo(Room::class);
    }

    public function enrollments()
    {
        return $this->hasMany(Enrollment::class);
    }

    public function sessions()
    {
        return $this->hasMany(Session::class);
    }

    public function activeEnrollments()
    {
        return $this->hasMany(Enrollment::class)->where('status', 'aktif');
    }

    public function students()
    {
        return $this->belongsToMany(Student::class, 'enrollments', 'school_class_id', 'student_id')
            ->withPivot('status')->withTimestamps();
    }
}
