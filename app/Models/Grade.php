<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Tanpa Blamable/soft delete seperti absensi: frekuensi bulk, penilai di graded_by.
 */
class Grade extends Model
{
    use HasFactory;

    protected $fillable = ['assessment_id', 'student_id', 'score', 'note', 'graded_by'];

    protected function casts(): array
    {
        return ['score' => 'decimal:2'];
    }

    public function assessment()
    {
        return $this->belongsTo(Assessment::class);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function grader()
    {
        return $this->belongsTo(User::class, 'graded_by');
    }
}
