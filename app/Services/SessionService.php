<?php

namespace App\Services;

use App\Models\CourseSetting;
use App\Models\Enrollment;
use App\Models\Schedule;
use App\Models\Session;
use Illuminate\Support\Carbon;

class SessionService
{
    /**
     * Apakah generate otomatis jatuh tempo saat ini, berdasarkan pengaturan
     * di database (frekuensi harian/mingguan/bulanan + jam).
     */
    public function shouldAutoGenerateToday(?CourseSetting $setting, ?Carbon $now = null): bool
    {
        if (! $setting || ! $setting->auto_generate_enabled) {
            return false;
        }
        $now ??= Carbon::now('Asia/Jakarta');
        [$hour, $minute] = array_map('intval', explode(':', (string) $setting->auto_generate_time));
        if ($now->copy()->setTime($hour, $minute)->greaterThan($now)) {
            return false;
        }

        return match ($setting->auto_generate_frequency) {
            'mingguan' => (int) $now->dayOfWeekIso === min(max((int) $setting->auto_generate_day, 1), 7),
            'bulanan' => (int) $now->day === min(max((int) $setting->auto_generate_day, 1), 28),
            default => true,
        };
    }

    /**
     * Buat sesi otomatis dari jadwal aktif untuk N minggu ke depan.
     * Idempoten: tanggal yang sudah ada sesinya dilewati.
     */
    public function autoGenerateUpcoming(int $weeksAhead = 3): array
    {
        $today = now('Asia/Jakarta')->toDateString();
        $endDate = now('Asia/Jakarta')->addWeeks($weeksAhead)->toDateString();

        $schedules = Schedule::where('is_active', true)->get();
        $created = 0;
        $skipped = 0;

        for ($date = now('Asia/Jakarta')->copy(); $date->lte($endDate); $date->addDay()) {
            foreach ($schedules as $schedule) {
                if ((int) $date->dayOfWeekIso !== (int) $schedule->day_of_week) {
                    continue;
                }
                $exists = Session::where('school_class_id', $schedule->school_class_id)
                    ->whereDate('session_date', $date->toDateString())
                    ->where('start_time', $schedule->start_time)
                    ->exists();
                if ($exists) {
                    $skipped++;

                    continue;
                }
                $class = $schedule->schoolClass;
                Session::create([
                    'school_class_id' => $schedule->school_class_id,
                    'schedule_id' => $schedule->id,
                    'session_date' => $date->toDateString(),
                    'start_time' => $schedule->start_time,
                    'end_time' => $schedule->end_time,
                    'room_id' => $schedule->room_id ?? $class->room_id,
                    'tutor_id' => $class->tutor_id,
                    'status' => 'terjadwal',
                ]);
                $created++;
            }
        }

        return ['created' => $created, 'skipped' => $skipped, 'until' => $endDate];
    }

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
