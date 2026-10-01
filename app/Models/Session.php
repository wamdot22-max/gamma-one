<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Session extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $table = 'class_sessions';

    protected $fillable = ['school_class_id', 'schedule_id', 'session_date', 'start_time', 'end_time', 'room_id', 'tutor_id', 'substitute_tutor_id', 'status', 'reason', 'material_notes', 'tutor_status'];

    protected function casts(): array
    {
        return ['session_date' => 'date'];
    }

    public function schoolClass()
    {
        return $this->belongsTo(SchoolClass::class);
    }

    public function schedule()
    {
        return $this->belongsTo(Schedule::class);
    }

    public function room()
    {
        return $this->belongsTo(Room::class);
    }

    public function tutor()
    {
        return $this->belongsTo(Tutor::class);
    }

    public function substitute()
    {
        return $this->belongsTo(Tutor::class, 'substitute_tutor_id');
    }

    public function substituteRequests()
    {
        return $this->hasMany(SessionSubstituteRequest::class);
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    public function activeStudents()
    {
        return Student::whereIn('id', Enrollment::where('school_class_id', $this->school_class_id)->where('status', 'aktif')->pluck('student_id'))->get();
    }
}
