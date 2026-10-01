FASE 0: Siapkan proyek berjalan di MySQL (Laragon).

1. Ubah .env.example: DB_CONNECTION=mysql, DB_HOST=127.0.0.1, DB_PORT=3306,
   DB_DATABASE=gamma_one, DB_USERNAME=root, DB_PASSWORD kosong. Atur
   APP_NAME="Gamma One", APP_TIMEZONE=Asia/Jakarta, APP_LOCALE=id,
   APP_FALLBACK_LOCALE=id. Ganti semua penyebutan PostgreSQL di README.md.
2. Periksa semua migration, seeder, dan query apakah kompatibel dengan MySQL 8
   dan SQLite; perbaiki bila ada masalah (jangan ubah fitur).
3. Jalankan php artisan migrate:fresh --seed pada MySQL, lalu php artisan test.
   Laporkan hasilnya.
4. Pastikan .gitignore mengecualikan .env, vendor, node_modules, dan folder build.
5. Tambahkan bagian "Menjalankan di Laragon" pada README (composer install,
   npm install, key:generate, migrate --seed, composer dev).

Selesai bila: aplikasi berjalan penuh di MySQL, tes lulus, dan tidak ada
penyebutan PostgreSQL yang tersisa.