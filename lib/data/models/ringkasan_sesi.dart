import 'truk.dart';

/// Hasil akhir satu sesi kerja, ditampilkan di layar "Sesi selesai".
class RingkasanSesi {
  const RingkasanSesi({
    this.sessionId = '',
    this.pending = 0,
    this.otomatis = false,
    required this.truk,
    required this.durasi,
    required this.ritase,
    required this.titikTerkirim,
    required this.mulai,
    required this.selesai,
  });

  final String sessionId;
  final int pending;
  final bool otomatis;
  final Truk truk;
  final Duration durasi;
  final int ritase;
  final int titikTerkirim;
  final DateTime mulai;
  final DateTime selesai;
}
