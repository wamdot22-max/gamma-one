<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>Laporan Pemasukan</title>
  <style>
    body { font-family: sans-serif; font-size: 12px; color: #222; }
    .header { border-bottom: 3px solid #0B4DA2; padding-bottom: 8px; margin-bottom: 16px; }
    .brand { font-size: 20px; font-weight: bold; color: #0B4DA2; }
    .tagline { font-size: 11px; color: #F9A825; font-weight: bold; }
    table { width: 100%; border-collapse: collapse; margin: 8px 0; }
    th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
    th { background: #0B4DA2; color: #fff; }
    .right { text-align: right; }
    .total { font-weight: bold; }
  </style>
</head>
<body>
  <div class="header">
    <div class="brand">Gamma One</div>
    <div class="tagline">One Step, One Growth.</div>
  </div>
  <h2>Laporan Pemasukan ({{ $group }})</h2>
  <table>
    <tr><th>Periode</th><th>Transaksi</th><th class="right">Total (Rp)</th></tr>
    @foreach ($rows as $row)
      <tr><td>{{ $row['periode'] }}</td><td>{{ $row['transaksi'] }}</td><td class="right">{{ number_format($row['total'], 0, ',', '.') }}</td></tr>
    @endforeach
    <tr><td colspan="2" class="total">Total</td><td class="right total">{{ number_format($total, 0, ',', '.') }}</td></tr>
  </table>
</body>
</html>
