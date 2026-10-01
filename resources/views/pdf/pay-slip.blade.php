<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>Slip Honor {{ $month }}</title>
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
  </style>
</head>
<body>
  <div class="header">
    <div class="brand">Gamma One</div>
    <div class="tagline">One Step, One Growth.</div>
  </div>
  <h2>Slip Honor Tutor — {{ $month }}</h2>
  <table>
    <tr><th width="35%">Tutor</th><td>{{ $tutor->name }}</td></tr>
    <tr><th>Honor per sesi</th><td class="right">Rp{{ number_format($row['fee_per_session'], 0, ',', '.') }}</td></tr>
    <tr><th>Jumlah sesi</th><td>{{ $row['sessions_count'] }} sesi</td></tr>
    <tr><td class="total">Total honor</td><td class="right total">Rp{{ number_format($row['total'], 0, ',', '.') }}</td></tr>
  </table>
  <h3>Rincian Sesi</h3>
  <table>
    <tr><th>Tanggal</th><th>Kelas</th><th>Peran</th><th class="right">Honor (Rp)</th></tr>
    @foreach ($row['sessions'] as $session)
      <tr><td>{{ $session['session_date'] }}</td><td>{{ $session['class'] }}</td><td>{{ $session['peran'] }}</td><td class="right">{{ number_format($session['honor'], 0, ',', '.') }}</td></tr>
    @endforeach
  </table>
</body>
</html>
