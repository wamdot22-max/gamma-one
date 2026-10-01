<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Program extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['name', 'description', 'fee', 'registration_fee', 'is_active'];

    protected function casts(): array
    {
        return ['fee' => 'integer', 'registration_fee' => 'integer', 'is_active' => 'boolean'];
    }

    public function schoolClasses()
    {
        return $this->hasMany(SchoolClass::class);
    }
}
