<?php

namespace App\Services\Notifications;

use App\Support\PhoneNumber;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class FonnteProvider implements NotificationProvider
{
    public function isFake(): bool
    {
        return ! $this->sendReal();
    }

    public function send(string $to, string $body, string $title = ''): void
    {
        $target = PhoneNumber::normalize($to);

        if ($this->isFake()) {
            Log::info('[NOTIF-UJI] WhatsApp tidak benar-benar dikirim.', ['target' => $target, 'body' => $body]);

            return;
        }

        $response = Http::withHeaders(['Authorization' => (string) config('services.fonnte.token')])
            ->asForm()->timeout(20)
            ->post('https://api.fonnte.com/send', ['target' => $target, 'message' => $body]);

        $json = $response->json();
        if (! $response->successful() || ($json['status'] ?? false) === false) {
            throw new RuntimeException('WhatsApp gagal: '.($json['reason'] ?? $response->body()));
        }
    }

    private function sendReal(): bool
    {
        return (bool) config('services.fonnte.send_real', false)
            && (string) config('services.fonnte.token') !== '';
    }
}
