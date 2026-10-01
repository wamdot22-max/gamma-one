<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Spatie\Permission\Models\Permission;

class PermissionGroup extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['name', 'slug', 'description'];

    public function permissions()
    {
        return $this->hasMany(Permission::class, 'permission_group_id');
    }
}
