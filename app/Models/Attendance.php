<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Tanpa trait Blamable dan soft delete: baris frekuensi tinggi yang
 * pelakunya tercatat di marked_by dan riwayat sesi di blamable_logs.
 */
class Attendance extends Model
{
    use HasFactory;

    public const STATUSES = ['hadir', 'izin', 'sakit', 'alfa'];

    protected $fillable = ['session_id', 'student_id', 'status', 'understanding', 'note', 'marked_by'];

    protected function casts(): array
    {
        return ['understanding' => 'integer'];
    }

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function marker()
    {
        return $this->belongsTo(User::class, 'marked_by');
    }
}
