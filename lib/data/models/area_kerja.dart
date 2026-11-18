import 'package:latlong2/latlong.dart';

enum JenisArea { muat, bongkar, pool }

/// Area kerja berbentuk poligon (geofence).
class AreaKerja {
  const AreaKerja({
    required this.nama,
    required this.jenis,
    required this.poligon,
    required this.durasiMinimum,
  });

  final String nama;
  final JenisArea jenis;
  final List<LatLng> poligon;

  /// Lama minimal truk berada di dalam area supaya dihitung sebagai
  /// muat atau bongkar. Melintas lebih singkat dari ini diabaikan.
  final Duration durasiMinimum;
}
