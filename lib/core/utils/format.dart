/// Fungsi format teks: durasi, waktu relatif, dan angka gaya Indonesia
/// (koma untuk desimal, titik untuk ribuan).
library;

String _duaDigit(int n) => n.toString().padLeft(2, '0');

/// Durasi sebagai jam:menit:detik, misalnya 5025 detik menjadi "01:23:45".
String formatDurasi(Duration durasi) {
  final total = durasi.inSeconds < 0 ? 0 : durasi.inSeconds;
  final jam = total ~/ 3600;
  final menit = (total % 3600) ~/ 60;
  final detik = total % 60;
  return '${_duaDigit(jam)}:${_duaDigit(menit)}:${_duaDigit(detik)}';
}

/// Selang waktu yang sudah lewat, misalnya 75 detik menjadi "1 mnt lalu".
String formatLalu(Duration selisih) {
  final detik = selisih.inSeconds;
  if (detik < 60) return 'baru saja';
  if (detik < 3600) return '${detik ~/ 60} mnt lalu';
  if (detik < 86400) return '${detik ~/ 3600} jam lalu';
  return '${detik ~/ 86400} hari lalu';
}

/// Angka gaya Indonesia: 12345.6 dengan satu desimal menjadi "12.345,6".
String formatAngka(num nilai, {int desimal = 0}) {
  final negatif = nilai < 0;
  final teks = nilai.abs().toStringAsFixed(desimal);
  final bagian = teks.split('.');
  final bulat = bagian[0];
  final penampung = StringBuffer();
  for (var i = 0; i < bulat.length; i++) {
    if (i > 0 && (bulat.length - i) % 3 == 0) penampung.write('.');
    penampung.write(bulat[i]);
  }
  if (desimal > 0) penampung.write(',${bagian[1]}');
  return '${negatif ? '-' : ''}$penampung';
}

/// Jarak: di bawah 1 km dalam meter (dibulatkan ke 10 m), sisanya km
/// dengan satu desimal. Contoh: "350 m", "1,8 km".
String formatJarak(double meter) {
  if (meter < 1000) {
    final bulat = (meter / 10).round() * 10;
    return '${formatAngka(bulat)} m';
  }
  return '${formatAngka(meter / 1000, desimal: 1)} km';
}

/// Kecepatan dari meter per detik ke "32 km/j".
String formatKecepatan(double meterPerDetik) =>
    '${formatAngka(meterPerDetik * 3.6)} km/j';

/// Jam dan menit gaya Indonesia, misalnya "14.05".
String formatJam(DateTime waktu) =>
    '${_duaDigit(waktu.hour)}.${_duaDigit(waktu.minute)}';

/// Tanggal dan jam setempat, misalnya "18 November 2026, 13.33".
String formatTanggalJam(DateTime waktu) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final lokal = waktu.toLocal();
  return '${lokal.day} ${bulan[lokal.month - 1]} ${lokal.year}, '
      '${formatJam(lokal)}';
}
