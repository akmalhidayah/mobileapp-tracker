import 'package:latlong2/latlong.dart';

/// Satu titik lokasi hasil perekaman GPS.
class TitikGps {
  const TitikGps({
    required this.lat,
    required this.lon,
    required this.akurasi,
    required this.kecepatan,
    required this.arah,
    required this.waktu,
    required this.seq,
    this.sessionId = '',
  });

  final double lat;
  final double lon;

  /// Akurasi horizontal dalam meter.
  final double akurasi;

  /// Kecepatan dalam meter per detik.
  final double kecepatan;

  /// Arah hadap dalam derajat, 0 = utara, searah jarum jam.
  final double arah;

  final DateTime waktu;

  /// Nomor urut titik dalam satu sesi.
  final int seq;
  final String sessionId;
  String get id => '$sessionId:$seq';

  LatLng get posisi => LatLng(lat, lon);
}
