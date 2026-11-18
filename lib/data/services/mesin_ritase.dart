import 'package:latlong2/latlong.dart';

import '../../core/utils/geo.dart';
import '../models/area_kerja.dart';
import '../models/status_perjalanan.dart';

/// Mesin konservatif: dwell diam, kualitas, jeda, dan dua titik keluar.
/// Ambang 1 m/s dan akurasi 30 m adalah asumsi demo, bukan konfigurasi tambang.
class MesinRitase {
  MesinRitase({
    required this.areaMuat,
    required this.areaBongkar,
    this.jedaMaksimum = const Duration(seconds: 35),
    this.ambangDiam = 1,
    this.akurasiMaksimum = 30,
  });
  final AreaKerja areaMuat, areaBongkar;
  final Duration jedaMaksimum;
  final double ambangDiam, akurasiMaksimum;
  StatusPerjalanan _status = StatusPerjalanan.kosong;
  int _ritase = 0, _diLuar = 0;
  DateTime? _diamSejak, _terakhir;
  bool _valid = false;
  bool perluDicek = false;
  StatusPerjalanan get status => _status;
  int get ritase => _ritase;

  void reset() {
    _ritase = 0;
    perluDicek = false;
    _terakhir = null;
    _batalkan();
  }

  void _batalkan() {
    _status = StatusPerjalanan.kosong;
    _diamSejak = null;
    _valid = false;
    _diLuar = 0;
  }

  void dataHilang() {
    perluDicek = true;
    _batalkan();
  }

  void _masuk(StatusPerjalanan status) {
    _status = status;
    _diamSejak = null;
    _valid = false;
    _diLuar = 0;
  }

  void proses(
    LatLng posisi,
    DateTime waktu, {
    double akurasi = 6,
    double kecepatan = 0,
  }) {
    if (_terakhir != null && !waktu.isAfter(_terakhir!)) return;
    if (_terakhir != null && waktu.difference(_terakhir!) > jedaMaksimum) {
      dataHilang();
    }
    _terakhir = waktu;
    if (!akurasi.isFinite ||
        akurasi > akurasiMaksimum ||
        akurasi < 0 ||
        !kecepatan.isFinite) {
      dataHilang();
      return;
    }
    final muat = titikDalamPoligon(posisi, areaMuat.poligon);
    final bongkar = titikDalamPoligon(posisi, areaBongkar.poligon);
    if (muat &&
        (_status == StatusPerjalanan.bermuatan ||
            _status == StatusPerjalanan.diDumping)) {
      perluDicek = true; // kembali muat: siklus sebelumnya batal
      _masuk(StatusPerjalanan.diLoading);
    }
    if (_status == StatusPerjalanan.kosong) {
      if (muat) {
        _masuk(StatusPerjalanan.diLoading);
      } else if (bongkar) {
        perluDicek = true;
      }
    } else if (_status == StatusPerjalanan.bermuatan && bongkar) {
      _masuk(StatusPerjalanan.diDumping);
    }
    final loading = _status == StatusPerjalanan.diLoading;
    if (!loading && _status != StatusPerjalanan.diDumping) return;
    final area = loading ? areaMuat : areaBongkar;
    if (loading ? muat : bongkar) {
      _diLuar = 0;
      if (kecepatan.abs() <= ambangDiam) {
        _diamSejak ??= waktu;
        if (waktu.difference(_diamSejak!) >= area.durasiMinimum) _valid = true;
      } else {
        _diamSejak = null;
      }
      return;
    }
    // Satu titik melompat melewati batas tidak cukup untuk transisi.
    _diamSejak = null;
    if (++_diLuar < 2) return;
    if (loading) {
      _status = _valid ? StatusPerjalanan.bermuatan : StatusPerjalanan.kosong;
    } else {
      if (_valid) _ritase++;
      _status = _valid ? StatusPerjalanan.kosong : StatusPerjalanan.bermuatan;
    }
    _valid = false;
    _diLuar = 0;
  }
}
