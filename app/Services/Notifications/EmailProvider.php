<?php

namespace App\Services\Notifications;

use App\Mail\NotificationMail;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

class EmailProvider implements NotificationProvider
{
    public function isFake(): bool
    {
        return ! $this->sendReal();
    }

    public function send(string $to, string $body, string $title = ''): void
    {
        if ($this->isFake()) {
            Log::info('[NOTIF-UJI] Email tidak benar-benar dikirim.', ['to' => $to, 'title' => $title]);

            return;
        }

        Mail::to($to)->send(new NotificationMail($title ?: 'Gamma One', $body));
    }

    private function sendReal(): bool
    {
        return (bool) config('services.fonnte.send_real', false)
            && (string) config('mail.mailers.smtp.host') !== '';
    }
}
