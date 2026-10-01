FASE 5: Notifikasi.

1. NotificationService memakai Laravel Queue (driver database, tabel jobs sudah
   ada): status pending/terkirim/gagal, retry, tabel notifications.
2. Interface provider + implementasi WhatsApp (Fonnte) dan email (SMTP). Token
   hanya di .env; nomor HP dinormalisasi ke format 62.
3. Template pesan Bahasa Indonesia yang bisa diedit admin: pengingat jadwal H-1,
   kehadiran ke orang tua, tagihan baru, pengingat jatuh tempo/tunggakan,
   konfirmasi pembayaran, selamat datang.
4. Halaman log notifikasi (admin) dan preferensi notifikasi per pengguna.
5. Bila WhatsApp gagal, kirim email dan tandai untuk tindak lanjut manual.
6. Sediakan mode uji: saat APP_ENV=local, pesan dicatat ke log dan tidak benar-
   benar dikirim, kecuali diaktifkan lewat .env.
7. Dokumentasikan cara menjalankan queue dan scheduler di Laragon
   (composer dev, php artisan schedule:work) dan nanti di VPS (Supervisor + cron).

Selesai bila: invoice baru dan absensi memicu notifikasi ke orang tua yang
benar, dan kegagalan tercatat.