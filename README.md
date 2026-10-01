# Gamma One

Aplikasi web manajemen bimbel "Gamma One" (tagline: "One Step, One Growth.") berbasis Laravel 13 dan Vue 3. Dibangun di atas template admin generik berbahasa Indonesia yang menyediakan autentikasi Sanctum, manajemen user/role/permission, menu dinamis, pengaturan aplikasi, upload file, dan audit log.

## Teknologi

- PHP 8.3+, Laravel 13, MySQL 8 / MariaDB, Laravel Sanctum, Spatie Permission
- Vue 3, Vite, Pinia, Vue Router, Vue Query, Ant Design Vue

## Instalasi

1. Salin konfigurasi lingkungan:

   ```powershell
   Copy-Item .env.example .env
   php artisan key:generate
   ```

2. Buat database MySQL bernama `gamma_one` (Laragon: database `gamma_one`, user `root` tanpa password secara default), lalu sesuaikan kredensial `.env`.

3. Pasang dependensi dan siapkan database:

   ```powershell
   composer install
   npm install
   php artisan migrate --seed
   npm run build
   ```

4. Jalankan API dan frontend:

   ```powershell
   php artisan serve
   npm run dev
   ```

## Menjalankan di Laragon

Windows + Laragon (MySQL lokal, tanpa Docker):

```powershell
composer install
Copy-Item .env.example .env
php artisan key:generate
# Pastikan MySQL Laragon berjalan dan database gamma_one sudah dibuat
php artisan migrate --seed
php artisan storage:link
npm install
```

Jalankan server dan Vite di dua terminal terpisah:

```powershell
# Terminal 1
php artisan serve

# Terminal 2
npm run dev
```

Opsional (terminal 3, bila butuh antrean):

```powershell
php artisan queue:listen --tries=1
```

> Catatan Windows: jangan pakai `composer dev` di Laragon karena perintah `php artisan pail` di dalamnya membutuhkan ekstensi `pcntl` yang tidak tersedia di PHP Windows sehingga semua proses ikut mati (`--kill-others`).
> Untuk build produksi: `npm run build`.

## Antrean & Penjadwal

Notifikasi, invoice bulanan, dan pengingat jadwal berjalan lewat antrean
(`QUEUE_CONNECTION=database`, tabel `jobs`) dan scheduler.

Laragon (Windows): jalankan di terminal terpisah:

```powershell
# Proses antrean notifikasi
php artisan queue:listen --tries=1

# Penjadwal: invoice tiap tanggal 1 jam 02:00, tunggakan harian jam 01:00,
# pengingat jadwal H-1 jam 19:00 (zona Asia/Jakarta)
php artisan schedule:work
```

Mode uji notifikasi: selama `APP_ENV=local` dan `NOTIFICATION_SEND_REAL=false`,
WhatsApp/email hanya dicatat ke log. Isi `FONNTE_TOKEN=...` dan
`NOTIFICATION_SEND_REAL=true` untuk pengiriman asli; kunci SMTP di `MAIL_*`
dan kunci Midtrans di `MIDTRANS_*`.

VPS (nanti): jalankan `queue:work` via Supervisor dan cron
`* * * * * php /var/www/gammaone/artisan schedule:run`.

## Akun Pengembangan

Seeder membuat akun lokal berikut:

- Email: `admin@dev.local`
- Password: `password123`
- Role: `super-admin`

Ganti password ini sebelum digunakan di lingkungan selain lokal.

## Menambahkan Modul Baru

Tambahkan migrasi, model, controller API di bawah `app/Http/Controllers/Api/V1`, route di `routes/api.php`, permission/role/menu pada seeder, lalu halaman Vue dan route yang sesuai. Endpoint terlindungi memakai Sanctum dan permission middleware; tidak ada ketergantungan cabang atau domain bisnis.

## Deploy VPS (Nginx + PHP-FPM + MySQL/MariaDB)

1. Siapkan server Ubuntu: PHP 8.3+ (`php-fpm`, `php-mysql`, `php-xml`, `php-mbstring`, `php-zip`, `php-gd`, `php-curl`), Composer, Node 20+, MySQL/MariaDB, Nginx, Supervisor.
2. Clone repo ke `/var/www/gammaone`, lalu:
   ```bash
   composer install --no-dev --optimize-autoloader
   cp .env.example .env
   php artisan key:generate
   # Isi DB_*, MIDTRANS_*, MAIL_*, FONNTE_TOKEN, NOTIFICATION_SEND_REAL=true
   php artisan migrate --force
   npm install && npm run build
   php artisan storage:link
   ```
3. Nginx: root ke `/var/www/gammaone/public`, `try_files $uri $uri/ /index.php?$query_string`, blokir akses `.env`; PHP via `php-fpm` socket. Pasang HTTPS (Certbot) — header HSTS aktif otomatis saat HTTPS.
4. Supervisor (2 program): `queue:work --tries=1` dan `schedule:work` (atau cron `* * * * * php /var/www/gammaone/artisan schedule:run >> /dev/null 2>&1`).
5. Backup harian otomatis (`app:backup-database` jam 02:30 via scheduler) ke `storage/app/backups` (7 berkas terbaru); salin keluar server secara berkala. Isi `MYSQLDUMP_PATH` bila `mysqldump` tidak ada di PATH.

## Panduan Singkat per Peran

- **Admin**: kelola semua (master, jadwal, keuangan, akademik, notifikasi, pengguna), pantau dashboard, atur profil bimbel di Pengaturan → Aplikasi.
- **Staf**: kelola data master, catat pembayaran tunai/transfer + bukti, buat invoice manual, lihat laporan dan log notifikasi.
- **Tutor**: menu Penjadwalan (Jadwal, Sesi & Absensi — tombol H/I/S/A + pindai QR), Akademik (input nilai, materi, tugas), Gaji Tutor (slip honor).
- **Siswa/Orang tua**: aplikasi mobile navigasi bawah — Beranda, Jadwal (jadwal + kehadiran), Nilai (grafik, rapor PDF, materi, tugas + kumpul berkas), Tagihan (tombol kuning Bayar sekarang + kuitansi), Profil.

## Verifikasi

```powershell
php artisan test
vendor\bin\pint --dirty
npm run build
```



