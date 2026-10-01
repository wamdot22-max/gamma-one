FASE 2: Data master bimbel.

1. Perluas pages/shared/CrudPage.vue agar mendukung tipe field: select (opsi dari
   API, bisa dicari), tanggal, jam, angka, switch, dan upload file. Jangan
   merusak halaman yang sudah memakainya.
2. Buat migration, model (Blamable + soft delete), controller, Form Request,
   route secureCrud, izin, menu, dan halaman Vue untuk: students, parents
   (many-to-many dengan siswa + jenis hubungan), tutors (mapel, honor per sesi,
   ketersediaan), programs, subjects, rooms, classes (program, mapel, tutor,
   ruangan, kapasitas, tipe reguler/privat), enrollments (cek kapasitas).
3. Kaitkan students/parents/tutors ke tabel users agar bisa login.
4. Impor siswa dari Excel/CSV (maatwebsite/excel) dengan laporan baris yang gagal.
5. Query scope/Policy kepemilikan: tutor hanya melihat kelasnya, orang tua hanya
   anaknya, siswa hanya dirinya.
6. Seeder contoh (fiktif): 20 siswa, 10 orang tua, 5 tutor, 6 kelas.
7. Tes: kapasitas kelas, dan akses silang (orang tua A tidak bisa membuka siswa
   milik orang tua B).

Selesai bila: admin/staf mengelola semua data master dan tes akses silang lulus.