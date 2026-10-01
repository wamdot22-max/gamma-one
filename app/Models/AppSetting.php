<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class AppSetting extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    protected $fillable = ['app_name', 'company_name', 'sidebar_logo_url', 'login_logo_url', 'favicon_url'];
}
