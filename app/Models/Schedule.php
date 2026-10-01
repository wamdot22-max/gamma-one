<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Schedule extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    public const DAYS = [1 => 'Senin', 2 => 'Selasa', 3 => 'Rabu', 4 => 'Kamis', 5 => 'Jumat', 6 => 'Sabtu', 7 => 'Minggu'];

    protected $fillable = ['school_class_id', 'day_of_week', 'start_time', 'end_time', 'room_id', 'is_active'];

    protected function casts(): array
    {
        return ['day_of_week' => 'integer', 'is_active' => 'boolean'];
    }

    public function schoolClass()
    {
        return $this->belongsTo(SchoolClass::class);
    }

    public function room()
    {
        return $this->belongsTo(Room::class);
    }

    public function sessions()
    {
        return $this->hasMany(Session::class);
    }
}
