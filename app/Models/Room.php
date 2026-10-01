<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Room extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['name', 'capacity', 'location'];

    protected function casts(): array
    {
        return ['capacity' => 'integer'];
    }

    public function schoolClasses()
    {
        return $this->hasMany(SchoolClass::class);
    }
}
