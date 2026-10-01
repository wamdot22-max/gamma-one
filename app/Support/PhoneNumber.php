<?php

namespace App\Support;

class PhoneNumber
{
    /**
     * Normalisasi nomor HP Indonesia ke format 62xxxxxxxxxx.
     * Mengembalikan null bila input kosong, atau string digit apa adanya
     * bila tidak menyerupai nomor Indonesia (biar validasi yang menolak).
     */
    public static function normalize(?string $value): ?string
    {
        if ($value === null) {
            return null;
        }

        $digits = preg_replace('/\D+/', '', $value);

        if ($digits === null || $digits === '') {
            return null;
        }

        if (str_starts_with($digits, '62')) {
            return $digits;
        }

        if (str_starts_with($digits, '0')) {
            return '62'.substr($digits, 1);
        }

        // Nomor lokal tanpa 0 (mis. 812...) anggap nomor Indonesia.
        if (strlen($digits) >= 9 && strlen($digits) <= 14) {
            return '62'.$digits;
        }

        return $digits;
    }

    public static function isEmail(string $value): bool
    {
        return str_contains($value, '@');
    }
}
