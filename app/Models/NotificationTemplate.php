<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class NotificationTemplate extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    public const KEYS = ['jadwal_h1', 'kehadiran_ortu', 'tagihan_baru', 'tagihan_jatuh_tempo', 'pembayaran_lunas', 'selamat_datang', 'jadwal_berubah', 'sesi_batal'];

    protected $fillable = ['key', 'name', 'body', 'is_active'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }
}
