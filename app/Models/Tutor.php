<?php

namespace App\Models;

use App\Support\PhoneNumber;
use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Tutor extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['user_id', 'name', 'phone', 'fee_per_session', 'availability', 'bio'];

    protected function casts(): array
    {
        return ['fee_per_session' => 'integer', 'availability' => 'array'];
    }

    protected function phone(): Attribute
    {
        return Attribute::make(set: fn ($value) => PhoneNumber::normalize($value));
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function subjects()
    {
        return $this->belongsToMany(Subject::class, 'subject_tutor')->withTimestamps();
    }

    public function schoolClasses()
    {
        return $this->hasMany(SchoolClass::class);
    }
}
