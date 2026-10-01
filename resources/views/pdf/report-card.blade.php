<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>Rapor {{ $report['student']['nis'] }} {{ $report['month'] }}</title>
  <style>
    body { font-family: sans-serif; font-size: 12px; color: #222; }
    .header { border-bottom: 3px solid #0B4DA2; padding-bottom: 8px; margin-bottom: 16px; }
    .brand { font-size: 20px; font-weight: bold; color: #0B4DA2; }
    .tagline { font-size: 11px; color: #F9A825; font-weight: bold; }
    table { width: 100%; border-collapse: collapse; margin: 8px 0; }
    th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
    th { background: #0B4DA2; color: #fff; }
    .right { text-align: right; }
  </style>
</head>
<body>
  <div class="header">
    <div class="brand">Gamma One</div>
    <div class="tagline">One Step, One Growth.</div>
  </div>
  <h2>Rapor Bulanan — {{ $report['month'] }}</h2>
  <table>
    <tr><th width="35%">Nama</th><td>{{ $report['student']['name'] }} ({{ $report['student']['nis'] }})</td></tr>
    <tr><th>Sekolah</th><td>{{ $report['student']['school'] ?? '-' }}</td></tr>
    <tr><th>Orang tua/wali</th><td>{{ implode(', ', $report['student']['guardians']) }}</td></tr>
  </table>
  @foreach ($report['subjects'] as $subject)
    <h3>{{ $subject['subject']['name'] ?? 'Tanpa mapel' }} — Rata-rata: {{ $subject['average'] }}</h3>
    <table>
      <tr><th>Asesmen</th><th>Tipe</th><th>Tanggal</th><th class="right">Nilai</th></tr>
      @foreach ($subject['items'] as $item)
        <tr><td>{{ $item['title'] }}</td><td>{{ $item['type'] }}</td><td>{{ $item['date'] }}</td><td class="right">{{ $item['score'] }}</td></tr>
      @endforeach
    </table>
  @endforeach
  <h3>Kehadiran</h3>
  <table>
    <tr><th>Hadir</th><th>Izin</th><th>Sakit</th><th>Alfa</th></tr>
    <tr><td>{{ $report['attendance']['hadir'] }}</td><td>{{ $report['attendance']['izin'] }}</td><td>{{ $report['attendance']['sakit'] }}</td><td>{{ $report['attendance']['alfa'] }}</td></tr>
  </table>
  @if (count($report['tutor_notes']))
    <h3>Catatan Tutor</h3>
    <ul>
      @foreach ($report['tutor_notes'] as $note)
        <li>{{ $note }}</li>
      @endforeach
    </ul>
  @endif
</body>
</html>
