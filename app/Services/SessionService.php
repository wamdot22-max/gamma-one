<?php

namespace App\Services;

use App\Models\Enrollment;
use App\Models\Session;

class SessionService
{
    /**
     * Selesaikan otomatis sesi terjadwal yang tanggalnya lewat dan
     * absensinya sudah terisi penuh. Tanpa absensi tetap terbuka dan
     * muncul di "Perlu Perhatian".
     */
    public function autoCompletePastSessions(): int
    {
        $today = now('Asia/Jakarta')->toDateString();

        $sessions = Session::where('status', 'terjadwal')
            ->whereDate('session_date', '<', $today)->get();

        $done = 0;
        foreach ($sessions as $session) {
            $enrolled = Enrollment::where('school_class_id', $session->school_class_id)
                ->where('status', 'aktif')->count();
            if ($enrolled === 0) {
                continue;
            }
            $filled = $session->attendances()->count();
            if ($filled >= $enrolled) {
                $session->update(['status' => 'selesai']);
                $done++;
            }
        }

        return $done;
    }
}
