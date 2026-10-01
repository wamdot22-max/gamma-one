<?php

namespace App\Models;

use App\Support\PhoneNumber;
use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Guardian extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $table = 'parents';

    protected $fillable = ['user_id', 'name', 'phone', 'address'];

    protected function phone(): Attribute
    {
        return Attribute::make(set: fn ($value) => PhoneNumber::normalize($value));
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function students()
    {
        return $this->belongsToMany(Student::class, 'parent_student', 'parent_id', 'student_id')
            ->withPivot('relationship')->withTimestamps();
    }
}
