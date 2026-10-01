<?php

namespace App\Services;

use App\Jobs\SendNotification;
use App\Models\NotificationLog;
use App\Models\NotificationPreference;
use App\Models\NotificationTemplate;
use App\Models\Session;
use App\Models\Student;
use App\Models\User;
use Illuminate\Support\Carbon;

class NotificationService
{
    public const DEFAULTS = [
        'jadwal_h1' => ['name' => 'Pengingat jadwal H-1', 'body' => "Halo {nama},\nBesok {tanggal} ada jadwal {kelas} pukul {jam} untuk {siswa}.\n— Gamma One"],
        'kehadiran_ortu' => ['name' => 'Kehadiran ke orang tua', 'body' => "Halo {nama},\n{siswa} tercatat {status} pada {kelas} tanggal {tanggal}.\n— Gamma One"],
        'tagihan_baru' => ['name' => 'Tagihan baru', 'body' => "Halo {nama},\nTagihan {invoice} untuk {siswa} sebesar Rp{nominal}, jatuh tempo {jatuh_tempo}.\n— Gamma One"],
        'tagihan_jatuh_tempo' => ['name' => 'Pengingat jatuh tempo', 'body' => "Halo {nama},\nTagihan {invoice} untuk {siswa} sebesar Rp{nominal} telah jatuh tempo. Segera lunasi.\n— Gamma One"],
        'pembayaran_lunas' => ['name' => 'Konfirmasi pembayaran', 'body' => "Halo {nama},\nPembayaran Rp{nominal} untuk {invoice} diterima. Sisa Rp{sisa}.\n— Gamma One"],
        'selamat_datang' => ['name' => 'Selamat datang', 'body' => "Halo {nama},\nSelamat datang di Gamma One — One Step, One Growth.\n— Gamma One"],
        'jadwal_berubah' => ['name' => 'Sesi dijadwal ulang', 'body' => "Halo {nama},\nSesi {kelas} untuk {siswa} dijadwal ulang ke {tanggal} pukul {jam}. Alasan: {alasan}.\n— Gamma One"],
        'sesi_batal' => ['name' => 'Sesi dibatalkan', 'body' => "Halo {nama},\nSesi {kelas} untuk {siswa} tanggal {tanggal} dibatalkan. Alasan: {alasan}.\n— Gamma One"],
    ];

    public function render(string $key, array $data): string
    {
        $template = NotificationTemplate::where('key', $key)->where('is_active', true)->first();
        $body = $template?->body ?? self::DEFAULTS[$key]['body'] ?? '';

        foreach ($data as $name => $value) {
            $body = str_replace('{'.$name.'}', (string) $value, $body);
        }

        return $body;
    }

    /**
     * Kirim ke user sesuai preferensi: WA bila ada nomor + diaktifkan,
     * kalau tidak email. Mengembalikan log atau null bila tak ada kanal.
     */
    public function send(User $user, string $key, array $data = [], $related = null): ?NotificationLog
    {
        $pref = NotificationPreference::firstOrCreate(
            ['user_id' => $user->id],
            ['wa_enabled' => true, 'email_enabled' => true]
        );

        $channel = null;
        $phone = $user->phone;
        $email = $user->email;
        if ($phone && $pref->wa_enabled) {
            $channel = 'wa';
        } elseif ($email && $pref->email_enabled) {
            $channel = 'email';
        }
        if (! $channel) {
            return null;
        }

        $log = NotificationLog::create([
            'user_id' => $user->id,
            'phone' => $phone,
            'email' => $email,
            'channel' => $channel,
            'template_key' => $key,
            'body' => $this->render($key, ['nama' => $user->name, ...$data]),
            'status' => 'pending',
            'related_type' => $related ? $related::class : null,
            'related_id' => $related?->id,
        ]);

        SendNotification::dispatch($log->id);

        return $log;
    }

    /**
     * Kirim ke semua orang tua/wali siswa.
     *
     * @return int jumlah terkirim ke antrean
     */
    public function notifyParents(Student $student, string $key, array $data = [], $related = null): int
    {
        $count = 0;
        foreach ($student->guardians as $guardian) {
            $user = $guardian->user;
            if (! $user) {
                continue;
            }
            if ($this->send($user, $key, ['siswa' => $student->name, ...$data], $related)) {
                $count++;
            }
        }

        return $count;
    }

    /**
     * Pengingat H-1 untuk sesi terjadwal besok. Dipanggil scheduler harian.
     */
    public function sendScheduleReminders(): int
    {
        $tomorrow = Carbon::now('Asia/Jakarta')->addDay()->toDateString();
        $sessions = Session::with(['schoolClass.students.guardians.user'])
            ->whereDate('session_date', $tomorrow)
            ->where('status', 'terjadwal')->get();

        $count = 0;
        foreach ($sessions as $session) {
            $active = $session->schoolClass->students->where('pivot.status', 'aktif');
            foreach ($active as $student) {
                $count += $this->notifyParents($student, 'jadwal_h1', [
                    'tanggal' => $tomorrow,
                    'kelas' => $session->schoolClass->name,
                    'jam' => substr((string) $session->start_time, 0, 5),
                ], $session);
            }
        }

        return $count;
    }
}
