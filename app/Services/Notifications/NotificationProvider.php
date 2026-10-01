<?php

namespace App\Services\Notifications;

interface NotificationProvider
{
    /**
     * Kirim pesan. Lempar exception bila gagal.
     */
    public function send(string $to, string $body, string $title = ''): void;

    public function isFake(): bool;
}
