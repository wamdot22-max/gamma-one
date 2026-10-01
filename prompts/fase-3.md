FASE 3: Penjadwalan dan absensi.

Konvensi dari Fase 2 yang wajib diikuti: model SchoolClass (tabel school_classes)
dan Guardian (tabel parents); pakai App\Support\Ownership untuk scope
kepemilikan (tutor -> kelasnya, ortu -> anaknya, siswa -> dirinya); data di luar
scope dijawab 404; galat bisnis lewat exception khusus -> 422.

1. Jadwal mingguan per kelas (schedules: hari, jam mulai/selesai) dengan tampilan
   kalender mingguan. Kelola oleh admin/staf.
2. ScheduleConflictService: deteksi bentrok tutor, ruangan, dan siswa (siswa
   dilihat dari enrollment aktif), dengan pesan jelas. Dipakai saat simpan
   jadwal dan reschedule. Tes PHPUnit lengkap, termasuk kasus jam yang tepat
   bersambung (tidak dianggap bentrok).
3. Generate sesi (sessions) dari jadwal untuk rentang tanggal, tanpa membuat
   sesi ganda bila dijalankan ulang (idempoten). Reschedule atau batalkan sesi
   dengan alasan.
4. Absensi (attendances: hadir/izin/sakit/alpa) oleh tutor pada sesi kelasnya
   saja. Halaman mobile-first: daftar siswa, tombol besar H/I/S/A, progres
   "6 dari 8 terisi", tombol Simpan. Absensi via QR (siswa dipindai tutor),
   absensi tutor sendiri, dan catatan materi per sesi.
5. Rekap kehadiran per siswa/kelas/periode dengan ekspor Excel.
6. Portal siswa/orang tua (layout mobile dengan navigasi bawah, bukan sidebar
   admin): halaman Jadwal dan Kehadiran read-only, hanya data anaknya.
7. Daftarkan izin dan menu di seeder pada grup BARU di luar "Data Master"
   (mis. "Jadwal & Absensi") agar tidak terkena filter sidebar. Menu tutor:
   Jadwal Mengajar dan Absensi. Menu siswa/ortu ada di portal. Tes sidebar
   diperbarui sesuai menu baru, tanpa melonggarkan aturan bahwa siswa/ortu tidak
   melihat menu admin.
8. Seeder contoh: jadwal untuk 6 kelas dan sesi 2 minggu, tanpa bentrok.
9. Tes: bentrok tutor/ruangan/siswa, generate sesi idempoten, tutor tidak bisa
   mengabsen kelas lain, ortu tidak bisa melihat kehadiran anak orang lain.

Selesai bila: tidak ada jadwal bentrok, tutor bisa absen dari HP dengan sedikit
ketukan, dan tes akses silang lulus. Jalankan php artisan test,
vendor\bin\pint --dirty, dan npm run build lalu laporkan hasilnya.