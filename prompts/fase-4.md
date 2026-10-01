FASE 4: Keuangan (semua nominal bilangan bulat rupiah).

1. InvoiceService + scheduler (routes/console.php) membuat invoice bulanan dari
   enrollment aktif (biaya program, diskon, biaya pendaftaran), plus invoice
   manual. Generate harus idempoten (tidak ganda bila dijalankan ulang). Tes
   untuk kasus ini.
2. Pembayaran manual oleh staf (tunai/transfer + upload bukti), cicilan, status
   otomatis: belum bayar, sebagian, lunas, terlambat.
3. Interface PaymentGateway + implementasi Midtrans sandbox (QRIS/VA). Kunci
   hanya di .env. Webhook memverifikasi signature dan idempoten (transaksi yang
   sama tidak diproses dua kali). Tes untuk webhook ganda dan signature palsu.
4. Kuitansi PDF (dompdf) berlogo Gamma One.
5. Halaman Tagihan orang tua dengan tombol kuning "Bayar sekarang" dan riwayat
   pembayaran.
6. Daftar tunggakan, laporan pemasukan harian/bulanan dengan ekspor, penggajian
   tutor dari jumlah sesi + slip honor PDF.

Selesai bila: invoice -> bayar sandbox -> lunas otomatis -> kuitansi berjalan
end-to-end.