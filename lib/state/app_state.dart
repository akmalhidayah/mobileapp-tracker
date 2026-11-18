import 'dart:async';

import 'package:flutter/foundation.dart';

import '../app/nama_rute.dart';
import '../data/dummy/dummy_data.dart';
import '../data/models/pengaturan_hp.dart';
import '../data/models/area_kerja.dart';
import '../data/models/rute.dart';
import '../data/models/ringkasan_sesi.dart';
import '../data/models/snapshot_sesi.dart';
import '../data/models/supir.dart';
import '../data/models/truk.dart';
import '../data/services/tracking_service.dart';

class AppState extends ChangeNotifier {
  AppState({required this._layanan}) {
    _langganan = _layanan.perubahan.listen((s) {
      _sesi = s;
      _beriTahu();
    });
  }
  final TrackingService _layanan;
  late final StreamSubscription<SnapshotSesi> _langganan;
  Supir? _supir;
  bool _setuju = false, _mulai = false, _selesai = false, _dibuang = false;
  final _kesiapan = Map<PengaturanHp, bool>.of(DummyData.kesiapanAwal);
  Truk? _truk;
  SnapshotSesi? _sesi;
  bool _tileGagal = false;
  void _beriTahu() {
    if (!_dibuang) notifyListeners();
  }

  bool get sudahMasuk => _supir != null;
  Supir? get supir => _supir;
  static String normalisasiHp(String nilai) =>
      nilai.replaceAll(RegExp(r'[\s+().-]'), '');
  static bool hpValid(String nilai) =>
      RegExp(r'^\d{10,15}$').hasMatch(normalisasiHp(nilai));
  static bool pinValid(String nilai) => RegExp(r'^\d{6}$').hasMatch(nilai);

  /// Kunci pencocokan nomor HP: awalan 62 disamakan dengan 0.
  static String _kunciHp(String nilai) {
    final n = normalisasiHp(nilai);
    return n.startsWith('62') ? '0${n.substring(2)}' : n;
  }

  /// Akun supir untuk nomor [noHp], atau null jika belum terdaftar.
  static Supir? cariAkun(String noHp) {
    final kunci = _kunciHp(noHp);
    for (final akun in DummyData.akunSupir) {
      if (_kunciHp(akun.noHp) == kunci) return akun;
    }
    return null;
  }

  bool masuk({required String noHp, required String pin}) {
    if (sesiAktif || _mulai || !hpValid(noHp) || !pinValid(pin)) return false;
    final akun = cariAkun(noHp);
    if (akun == null) return false;
    _supir = Supir(
      nama: akun.nama,
      noHp: normalisasiHp(noHp),
      vendor: akun.vendor,
    );
    _setuju = false;
    _truk = null;
    _beriTahu();
    return true;
  }

  bool keluar() {
    if (sesiAktif || sibuk) return false;
    _supir = null;
    _setuju = false;
    _truk = null;
    _beriTahu();
    return true;
  }

  bool get sudahSetuju => _setuju;
  void setuju() {
    if (!sudahMasuk) return;
    _setuju = true;
    _beriTahu();
  }

  bool siap(PengaturanHp p) {
    if (p == PengaturanHp.gps && simulasiGpsMati) return false;
    if (p == PengaturanHp.izinLokasi && izinDicabut) return false;
    return _kesiapan[p] ?? false;
  }

  int get jumlahPengaturan => PengaturanHp.values.length;
  int get jumlahSiap => PengaturanHp.values.where(siap).length;
  bool get semuaSiap => jumlahSiap == jumlahPengaturan;
  void tandaiSiap(PengaturanHp p) {
    _kesiapan[p] = true;
    if (p == PengaturanHp.gps) _kendali?.simulasiGpsMati = false;
    if (p == PengaturanHp.izinLokasi) _kendali?.izinDicabut = false;
    _beriTahu();
  }

  /// Hanya nomor lambung yang ditag untuk vendor akun supir ini.
  List<Truk> get daftarTruk {
    final vendor = _supir?.vendor;
    if (vendor == null) return const [];
    return [
      for (final truk in vendor.daftarTruk)
        if (truk.vendorId == vendor.id) truk,
    ];
  }

  AreaKerja get areaMuat => DummyData.areaMuat;
  AreaKerja get areaBongkar => DummyData.areaBongkar;
  Rute get ruteHauling => DummyData.ruteHauling;
  Truk? get truk => _truk;
  bool pilihTruk(Truk truk) {
    if (!sudahMasuk ||
        !_setuju ||
        sesiAktif ||
        sibuk ||
        truk.vendorId != _supir!.vendor.id ||
        !daftarTruk.contains(truk)) {
      return false;
    }
    _truk = truk;
    _beriTahu();
    return true;
  }

  bool get sesiAktif => _layanan.terkini?.aktif ?? false;
  SnapshotSesi? get sesi => _sesi ?? _layanan.terkini;
  bool get sibuk => _mulai || _selesai;
  bool get bolehMulai =>
      sudahMasuk &&
      _setuju &&
      semuaSiap &&
      _truk != null &&
      !sesiAktif &&
      !sibuk;
  Future<bool> mulaiSesi() async {
    if (!bolehMulai) return false;
    _mulai = true;
    _beriTahu();
    try {
      await _layanan.mulai(nomorTruk: _truk!.nomor);
      return sesiAktif;
    } catch (_) {
      return false;
    } finally {
      _mulai = false;
      _beriTahu();
    }
  }

  Future<void> kirimSekarang() => _layanan.kirimSekarang();
  Future<void> selesaiSesi() async {
    if (!sesiAktif || _selesai) return;
    _selesai = true;
    _beriTahu();
    try {
      await _layanan.selesai();
    } finally {
      _selesai = false;
      _beriTahu();
    }
  }

  List<RingkasanSesi> get riwayat => _layanan.riwayat
      .map(
        (s) => RingkasanSesi(
          sessionId: s.sessionId,
          truk: DummyData.daftarTruk.firstWhere((t) => t.nomor == s.nomorTruk),
          durasi: s.durasi,
          ritase: s.ritase,
          titikTerkirim: s.titikTerkirim,
          pending: s.belumTerkirim,
          mulai: s.mulai,
          selesai: s.waktu,
          otomatis: s.otomatis,
        ),
      )
      .toList();
  RingkasanSesi? get ringkasanTerakhir => riwayat.isEmpty ? null : riwayat.last;
  int get pendingLama => riwayat.fold(0, (n, s) => n + s.pending);
  String get ruteSemestinya {
    if (!sudahMasuk) return NamaRute.masuk;
    if (sesiAktif) return NamaRute.sesi;
    if (!_setuju) return NamaRute.persetujuan;
    if (!semuaSiap && _truk == null) return NamaRute.kesiapan;
    if (_truk == null) return NamaRute.pilihTruk;
    return NamaRute.beranda;
  }

  String lindungiRute(String nama) {
    if (kDebugMode && (nama == NamaRute.debug || nama == NamaRute.galeri)) {
      return nama;
    }
    if (!sudahMasuk) {
      return nama == NamaRute.awal ? NamaRute.awal : NamaRute.masuk;
    }
    if (sesiAktif) return nama == NamaRute.peta ? nama : NamaRute.sesi;
    if (!_setuju) return NamaRute.persetujuan;
    if ((nama == NamaRute.ringkasan ||
            nama == NamaRute.sesi ||
            nama == NamaRute.peta) &&
        ringkasanTerakhir != null) {
      return NamaRute.ringkasan;
    }
    if (nama == NamaRute.kesiapan) return nama;
    if (!semuaSiap && _truk == null) return NamaRute.kesiapan;
    if (_truk == null || nama == NamaRute.pilihTruk) return NamaRute.pilihTruk;
    return NamaRute.beranda;
  }

  KendaliSimulasi? get _kendali =>
      _layanan is KendaliSimulasi ? _layanan as KendaliSimulasi : null;
  bool get adaKendaliSimulasi => kDebugMode && _kendali != null;
  bool get simulasiGpsMati => _kendali?.simulasiGpsMati ?? false;
  set simulasiGpsMati(bool v) {
    _kendali?.simulasiGpsMati = v;
    _beriTahu();
  }

  bool get izinDicabut => _kendali?.izinDicabut ?? false;
  set izinDicabut(bool v) {
    _kendali?.izinDicabut = v;
    _beriTahu();
  }

  bool get uploadOffline => _kendali?.uploadOffline ?? false;
  set uploadOffline(bool v) {
    _kendali?.uploadOffline = v;
    _beriTahu();
  }

  bool get gagalUpload => _kendali?.gagalUpload ?? false;
  set gagalUpload(bool v) {
    _kendali?.gagalUpload = v;
    _beriTahu();
  }

  int get baterai => _kendali?.baterai ?? 72;
  set baterai(int v) {
    _kendali?.baterai = v;
    _beriTahu();
  }

  bool get charging => _kendali?.charging ?? true;
  set charging(bool v) {
    _kendali?.charging = v;
    _beriTahu();
  }

  int get percepatan => _kendali?.percepatan ?? 1;
  set percepatan(int v) {
    _kendali?.percepatan = v;
    _beriTahu();
  }

  bool get tileGagal => _tileGagal;
  set tileGagal(bool v) {
    _tileGagal = v;
    _beriTahu();
  }

  void lompatKe(Duration durasi) => _kendali?.lompatKe(durasi);
  Future<void> resetSemua() async {
    await _layanan.reset();
    _supir = null;
    _setuju = false;
    _truk = null;
    _sesi = null;
    _tileGagal = false;
    _mulai = false;
    _selesai = false;
    _kesiapan
      ..clear()
      ..addAll(DummyData.kesiapanAwal);
    _beriTahu();
  }

  @override
  void dispose() {
    _dibuang = true;
    _langganan.cancel();
    _layanan.dispose();
    super.dispose();
  }
}
