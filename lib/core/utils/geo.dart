/// Fungsi geometri sederhana untuk geofence dan rute.
library;

import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

const Distance _jarak = Distance(roundResult: false);

/// Jarak garis lurus dua titik dalam meter.
double jarakMeter(LatLng a, LatLng b) => _jarak.distance(a, b);

/// Apakah [titik] berada di dalam [poligon]. Memakai ray casting: tarik
/// garis mendatar dari titik ke kanan dan hitung berapa sisi yang
/// terpotong. Jumlah ganjil berarti di dalam.
bool titikDalamPoligon(LatLng titik, List<LatLng> poligon) {
  if (poligon.length < 3) return false;
  final x = titik.longitude;
  final y = titik.latitude;
  var diDalam = false;
  for (var i = 0, j = poligon.length - 1; i < poligon.length; j = i++) {
    final xi = poligon[i].longitude;
    final yi = poligon[i].latitude;
    final xj = poligon[j].longitude;
    final yj = poligon[j].latitude;
    final memotong =
        (yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi;
    if (memotong) diDalam = !diDalam;
  }
  return diDalam;
}

/// Titik tengah poligon (rata-rata sudutnya), cukup untuk menaruh label.
LatLng pusatPoligon(List<LatLng> poligon) {
  var lat = 0.0;
  var lon = 0.0;
  for (final p in poligon) {
    lat += p.latitude;
    lon += p.longitude;
  }
  return LatLng(lat / poligon.length, lon / poligon.length);
}

/// Arah dari [a] ke [b] dalam derajat, 0 = utara, searah jarum jam.
double arahDerajat(LatLng a, LatLng b) {
  final lat1 = a.latitudeInRad;
  final lat2 = b.latitudeInRad;
  final dLon = b.longitudeInRad - a.longitudeInRad;
  final y = math.sin(dLon) * math.cos(lat2);
  final x =
      math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// Titik di antara [a] dan [b]; [t] = 0 berarti a, 1 berarti b.
LatLng antara(LatLng a, LatLng b, double t) => LatLng(
  a.latitude + (b.latitude - a.latitude) * t,
  a.longitude + (b.longitude - a.longitude) * t,
);

/// Garis rute yang bisa ditanya "posisi pada meter ke-sekian".
class Lintasan {
  Lintasan(this.titik) : assert(titik.length >= 2) {
    var total = 0.0;
    _kumulatif.add(0);
    for (var i = 1; i < titik.length; i++) {
      total += jarakMeter(titik[i - 1], titik[i]);
      _kumulatif.add(total);
    }
  }

  final List<LatLng> titik;
  final List<double> _kumulatif = [];

  /// Panjang seluruh lintasan dalam meter.
  double get panjang => _kumulatif.last;

  int _segmenPada(double meter) {
    for (var i = 1; i < _kumulatif.length; i++) {
      if (meter <= _kumulatif[i]) return i - 1;
    }
    return titik.length - 2;
  }

  /// Posisi pada [meter] dari awal lintasan.
  LatLng posisiPada(double meter) {
    final m = meter.clamp(0.0, panjang);
    final i = _segmenPada(m);
    final panjangSegmen = _kumulatif[i + 1] - _kumulatif[i];
    final t = panjangSegmen == 0 ? 0.0 : (m - _kumulatif[i]) / panjangSegmen;
    return antara(titik[i], titik[i + 1], t);
  }

  /// Arah lintasan (ke depan) pada [meter], dalam derajat.
  double arahPada(double meter) {
    final i = _segmenPada(meter.clamp(0.0, panjang));
    return arahDerajat(titik[i], titik[i + 1]);
  }

  /// Meter dari awal lintasan untuk titik lintasan yang paling dekat
  /// dengan [posisi].
  double meterTerdekat(LatLng posisi) {
    var terbaik = 0.0;
    var jarakTerbaik = double.infinity;
    // Proyeksi datar; cukup teliti untuk jarak beberapa kilometer.
    final skalaLon = math.cos(posisi.latitudeInRad);
    final px = posisi.longitude * skalaLon;
    final py = posisi.latitude;
    for (var i = 0; i < titik.length - 1; i++) {
      final ax = titik[i].longitude * skalaLon;
      final ay = titik[i].latitude;
      final bx = titik[i + 1].longitude * skalaLon;
      final by = titik[i + 1].latitude;
      final dx = bx - ax;
      final dy = by - ay;
      final panjangKuadrat = dx * dx + dy * dy;
      final t = panjangKuadrat == 0
          ? 0.0
          : (((px - ax) * dx + (py - ay) * dy) / panjangKuadrat).clamp(
              0.0,
              1.0,
            );
      final qx = ax + dx * t;
      final qy = ay + dy * t;
      final jarak = (px - qx) * (px - qx) + (py - qy) * (py - qy);
      if (jarak < jarakTerbaik) {
        jarakTerbaik = jarak;
        terbaik = _kumulatif[i] + (_kumulatif[i + 1] - _kumulatif[i]) * t;
      }
    }
    return terbaik;
  }
}
