<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NotificationLog extends Model
{
    use HasFactory;

    protected $table = 'notifications';

    public const STATUSES = ['pending', 'terkirim', 'gagal'];

    protected $fillable = ['user_id', 'phone', 'email', 'channel', 'template_key', 'body', 'status', 'attempts', 'error', 'related_type', 'related_id', 'needs_follow_up', 'sent_at'];

    protected function casts(): array
    {
        return ['needs_follow_up' => 'boolean', 'sent_at' => 'datetime'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function related()
    {
        return $this->morphTo();
    }
}
