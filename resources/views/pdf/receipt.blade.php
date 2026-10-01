<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>Kuitansi {{ $invoice->invoice_no }}</title>
  <style>
    body { font-family: sans-serif; font-size: 12px; color: #222; }
    .header { border-bottom: 3px solid #0B4DA2; padding-bottom: 8px; margin-bottom: 16px; }
    .brand { font-size: 20px; font-weight: bold; color: #0B4DA2; }
    .tagline { font-size: 11px; color: #F9A825; font-weight: bold; }
    table { width: 100%; border-collapse: collapse; margin: 8px 0; }
    th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
    th { background: #0B4DA2; color: #fff; }
    .right { text-align: right; }
    .total { font-weight: bold; font-size: 14px; }
    .lunas { color: #16a34a; font-weight: bold; font-size: 16px; }
  </style>
</head>
<body>
  <div class="header">
    <div class="brand">Gamma One</div>
    <div class="tagline">One Step, One Growth.</div>
  </div>
  <h2>Kuitansi Pembayaran</h2>
  <table>
    <tr><th width="35%">No. Invoice</th><td>{{ $invoice->invoice_no }}</td></tr>
    <tr><th>Siswa</th><td>{{ $invoice->student->name ?? '-' }} ({{ $invoice->student->nis ?? '-' }})</td></tr>
    <tr><th>Kelas</th><td>{{ $invoice->schoolClass->name ?? '-' }}</td></tr>
    <tr><th>Periode</th><td>{{ $invoice->period ?? '-' }}</td></tr>
    <tr><th>Status</th><td class="lunas">{{ strtoupper(str_replace('_', ' ', $invoice->status)) }}</td></tr>
  </table>
  <table>
    <tr><th>Uraian</th><th class="right">Nominal (Rp)</th></tr>
    <tr><td>Biaya program</td><td class="right">{{ number_format($invoice->amount, 0, ',', '.') }}</td></tr>
    <tr><td>Biaya pendaftaran</td><td class="right">{{ number_format($invoice->registration_fee, 0, ',', '.') }}</td></tr>
    <tr><td>Diskon</td><td class="right">-{{ number_format($invoice->discount, 0, ',', '.') }}</td></tr>
    <tr><td class="total">Total</td><td class="right total">{{ number_format($invoice->total, 0, ',', '.') }}</td></tr>
    <tr><td>Dibayar</td><td class="right">{{ number_format($invoice->paid_amount, 0, ',', '.') }}</td></tr>
  </table>
  <h3>Riwayat Pembayaran</h3>
  <table>
    <tr><th>Tanggal</th><th>Metode</th><th>Referensi</th><th class="right">Nominal (Rp)</th></tr>
    @foreach ($invoice->payments as $payment)
      <tr>
        <td>{{ $payment->paid_at }}</td>
        <td>{{ $payment->method }}</td>
        <td>{{ $payment->reference ?? '-' }}</td>
        <td class="right">{{ number_format($payment->amount, 0, ',', '.') }}</td>
      </tr>
    @endforeach
  </table>
</body>
</html>
