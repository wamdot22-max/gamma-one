<?php

namespace App\Models;

use App\Traits\Blamable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SessionSubstituteRequest extends Model
{
    use Blamable, HasFactory, SoftDeletes;

    public const STATUSES = ['diusulkan', 'disetujui', 'ditolak'];

    protected $fillable = ['session_id', 'original_tutor_id', 'proposed_tutor_id', 'reason', 'status', 'requested_by', 'reviewed_by', 'reviewed_at', 'review_note'];

    protected function casts(): array
    {
        return ['reviewed_at' => 'datetime'];
    }

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function originalTutor()
    {
        return $this->belongsTo(Tutor::class, 'original_tutor_id');
    }

    public function proposedTutor()
    {
        return $this->belongsTo(Tutor::class, 'proposed_tutor_id');
    }

    public function requester()
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function reviewer()
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }
}
