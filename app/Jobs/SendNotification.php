<?php

namespace App\Jobs;

use App\Models\NotificationLog;
use App\Services\Notifications\EmailProvider;
use App\Services\Notifications\FonnteProvider;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Throwable;

class SendNotification implements ShouldQueue
{
    use Queueable;

    public $tries = 3;

    public $backoff = [60, 300, 900];

    public function __construct(public int $notificationId) {}

    public function handle(FonnteProvider $wa, EmailProvider $email): void
    {
        $notification = NotificationLog::findOrFail($this->notificationId);

        // Sudah diproses (mis. retry terlambat datang setelah sukses).
        if ($notification->status === 'terkirim') {
            return;
        }

        $notification->attempts++;
        $notification->save();

        try {
            if ($notification->channel === 'email') {
                $email->send($notification->email, $notification->body);
            } else {
                $wa->send($notification->phone, $notification->body);
            }
            $notification->update(['status' => 'terkirim', 'error' => null, 'sent_at' => now()]);
        } catch (Throwable $e) {
            // Fallback: bila WhatsApp gagal, coba email lalu tandai tindak lanjut manual.
            if ($notification->channel === 'wa' && $notification->email) {
                try {
                    $email->send($notification->email, $notification->body);
                    $notification->update([
                        'status' => 'terkirim', 'channel' => 'email',
                        'needs_follow_up' => true, 'error' => 'WA gagal: '.$e->getMessage(),
                        'sent_at' => now(),
                    ]);

                    return;
                } catch (Throwable $emailError) {
                    $this->markFailed($notification, 'WA: '.$e->getMessage().' | Email: '.$emailError->getMessage());

                    return;
                }
            }

            $this->markFailed($notification, $e->getMessage());
        }
    }

    public function failed(?Throwable $e): void
    {
        $notification = NotificationLog::find($this->notificationId);
        if ($notification && $notification->status !== 'terkirim') {
            $this->markFailed($notification, $e?->getMessage() ?? 'Gagal setelah 3 percobaan.');
        }
    }

    private function markFailed(NotificationLog $notification, string $error): void
    {
        // Lempar agar queue me-retry; status gagal final ditulis di failed().
        if ($notification->attempts < $this->tries) {
            $notification->update(['error' => $error]);

            throw new \RuntimeException($error);
        }

        $notification->update(['status' => 'gagal', 'error' => $error, 'needs_follow_up' => true]);
    }
}
