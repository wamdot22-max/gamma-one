FASE 7: Dashboard dan finalisasi.

1. Dashboard admin/staf: siswa aktif, pemasukan bulan ini, tunggakan, tingkat
   kehadiran, jadwal hari ini, daftar perlu ditagih, grafik pemasukan 6 bulan.
   Endpoint lewat DashboardController dengan cache singkat.
2. Laporan dengan filter periode dan ekspor Excel/PDF.
3. Pengaturan bimbel (profil, tahun ajaran, biaya, template pesan) lewat halaman
   pengaturan template.
4. PWA: manifest, ikon Gamma One, service worker sederhana.
5. Optimasi: indeks database, eager loading, target halaman < 3 detik.
6. Keamanan: rate limit login, tinjau seluruh route untuk IDOR dan izin, header
   keamanan, backup database harian (mysqldump terjadwal).
7. Dokumentasi: README, panduan deploy VPS (Nginx, PHP-FPM, MySQL/MariaDB,
   Supervisor, cron, HTTPS), dan panduan singkat per peran.
8. Tes alur utama: daftar -> jadwal -> absen -> bayar -> rapor.
9. Audit repositori sebelum push ke GitHub: pastikan tidak ada rahasia atau data
   siswa asli yang ter-commit, dan .env.example lengkap.

Selesai bila: alur utama lolos tes dan repositori bersih siap di-push.