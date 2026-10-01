FASE 1: Adaptasi template ke Gamma One.

1. Identitas: nama aplikasi "Gamma One" di app settings dan seeder, logo
   placeholder, favicon, judul halaman, tema Ant Design (token warna biru/kuning,
   font Nunito, sudut membulat).
2. Halaman login bertema Gamma One: panel biru berisi tagline "One Step, One
   Growth." + form masuk (email/no HP + password). Tambahkan alur lupa/reset
   kata sandi bila belum ada.
3. Tambahkan 5 peran (admin, staf, tutor, siswa, orang_tua) dan kelompok izin
   awal di seeder, lengkap dengan menu sidebar per peran (maks. 7 menu).
   Izin modul bimbel didaftarkan bertahap di fase berikutnya.
4. Buat layout portal mobile-first (navigasi bawah) untuk siswa/orang tua;
   arahkan redirect setelah login sesuai peran.
5. Periksa dan laporkan: cara token disimpan di browser dan risikonya, apakah
   AppLayout responsif di layar HP. Perbaiki bila perlu.
6. Ubah dashboard menjadi kerangka per peran (isi menyusul di Fase 7).
7. Seeder satu akun contoh per peran. Tes: akses menu dan endpoint per peran
   (403 bila terlarang).

Selesai bila: tiap peran hanya melihat menunya sendiri, tampilan di lebar HP
layak, dan semua tes lulus.