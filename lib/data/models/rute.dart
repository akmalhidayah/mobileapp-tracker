import 'package:latlong2/latlong.dart';

/// Rute resmi hauling dari area muat ke area bongkar.
class Rute {
  const Rute({
    required this.nama,
    required this.garis,
    required this.toleransiMeter,
    required this.versi,
  });

  final String nama;
  final List<LatLng> garis;

  /// Jarak maksimal dari garis rute yang masih dianggap di dalam rute.
  final double toleransiMeter;
  final int versi;
}
