import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/nama_rute.dart';
import '../data/dummy/dummy_data.dart';
import '../data/models/pengaturan_hp.dart';
import '../data/models/area_kerja.dart';
import '../data/models/rute.dart';
import '../data/models/ringkasan_sesi.dart';
import '../data/models/snapshot_sesi.dart';
import '../data/models/supir.dart';
import '../data/models/truk.dart';
import '../data/services/akun_sopir_api.dart';
import '../data/services/tracking_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this._layanan,
    AkunSopirApi? apiAkun,
    this._preferensi,
    this.loginDemo = false,
  }) : _api = apiAkun {
    _langganan = _layanan.perubahan.listen((s) {
      _sesi = s;
      _beriTahu();
    });
  }
  final TrackingService _layanan;
  final AkunSopirApi? _api;
  final SharedPreferencesAsync? _preferensi;
  static const _kunciKesiapan = 'tracker_tonasa_kesiapan_simulasi';
  late final StreamSubscription<SnapshotSesi> _langganan;
  Supir? _supir;
  bool _setuju = false, _mulai = false, _selesai = false, _dibuang = false;
  final _kesiapan = Map<PengaturanHp, bool>.of(DummyData.kesiapanAwal);
  Truk? _truk;
  SnapshotSesi? _sesi;
  final _identitasSesi = <String, ({String hp, Truk truk})>{};
  bool _akunSibuk = false;
  String? pesanAkun;
  bool get akunSibuk => _akunSibuk;
  final bool loginDemo;
  bool get loginTersedia => _api != null || loginDemo;
  bool _tileGagal = false;
  void _beriTahu() {
    if (!_dibuang) notifyListeners();
  }

  bool get sudahMasuk => _supir != null;
  bool get perluPulihkanLogin => _api != null && !sudahMasuk;
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

  Future<bool> pulihkanLogin() => _ubahAkun(() async {
    final kesiapan = await _preferensi?.getStringList(_kunciKesiapan);
    if (kesiapan != null) {
      for (final pengaturan in PengaturanHp.values) {
        _kesiapan[pengaturan] = kesiapan.contains(pengaturan.name);
      }
    }
    final profil = await _api?.pulihkan();
    if (profil != null) _terapkanProfil(profil);
  });

  void _terapkanProfil(ProfilSopir profil) {
    _supir = profil.supir;
    _setuju = profil.sudahSetuju;
    _truk = daftarTruk
        .where((truk) => truk.id == profil.trukTerpilihId)
        .firstOrNull;
  }

  Future<bool> masuk({required String noHp, required String pin}) async {
    if (sudahMasuk ||
        sesiAktif ||
        sibuk ||
        _akunSibuk ||
        !hpValid(noHp) ||
        !pinValid(pin)) {
      return false;
    }
    return _ubahAkun(() async {
      final api = _api;
      if (api != null) {
        _terapkanProfil(await api.masuk(noHp: noHp, pin: pin));
      } else if (loginDemo) {
        final akun = cariAkun(noHp);
        if (akun == null || pin != '123456') {
          throw const KesalahanAkun('Periksa kembali nomor HP dan PIN Anda.');
        }
        _supir = Supir(
          nama: akun.nama,
          noHp: normalisasiHp(noHp),
          vendor: akun.vendor,
        );
      } else {
        throw const KesalahanAkun(
          'Server login belum dikonfigurasi. Hubungi admin.',
        );
      }
      _sesi = null;
    });
  }

  Future<bool> keluar() async {
    if (sesiAktif || sibuk || _akunSibuk) return false;
    return _ubahAkun(() async {
      await _api?.keluar();
      _hapusAkun();
    });
  }

  Future<bool> muatPenugasan() async {
    final api = _api;
    if (api == null || !sudahMasuk || sesiAktif || sibuk || _akunSibuk) {
      return false;
    }
    return _ubahAkun(() async {
      _terapkanProfil(await api.periksaSesi());
    });
  }

  Future<bool> _ubahAkun(Future<void> Function() proses) async {
    _akunSibuk = true;
    pesanAkun = null;
    _beriTahu();
    try {
      await proses();
      return true;
    } on KesalahanAkun catch (error) {
      if (error.sesiHabis) _hapusAkun();
      pesanAkun = error.pesan;
      return false;
    } catch (_) {
      pesanAkun = 'Terjadi gangguan. Coba lagi.';
      return false;
    } finally {
      _akunSibuk = false;
      _beriTahu();
    }
  }

  void _hapusAkun() {
    _supir = null;
    _setuju = false;
    _truk = null;
    _sesi = null;
  }

  bool get sudahSetuju => _setuju;
  Future<bool> setuju() async {
    if (!sudahMasuk || sesiAktif || _akunSibuk) return false;
    return _ubahAkun(() async {
      await _api?.setuju();
      _setuju = true;
    });
  }

  bool siap(PengaturanHp p) {
    if (p == PengaturanHp.gps && simulasiGpsMati) return false;
    if (p == PengaturanHp.izinLokasi && izinDicabut) return false;
    return _kesiapan[p] ?? false;
  }

  int get jumlahPengaturan => PengaturanHp.values.length;
  int get jumlahSiap => PengaturanHp.values.where(siap).length;
  bool get semuaSiap => jumlahSiap == jumlahPengaturan;
  Future<void> tandaiSiap(PengaturanHp p) async {
    _kesiapan[p] = true;
    if (p == PengaturanHp.gps) _kendali?.simulasiGpsMati = false;
    if (p == PengaturanHp.izinLokasi) _kendali?.izinDicabut = false;
    _beriTahu();
    await _preferensi?.setStringList(_kunciKesiapan, [
      for (final entri in _kesiapan.entries)
        if (entri.value) entri.key.name,
    ]);
  }

  /// Daftar penugasan dari akun sopir.
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
  Future<bool> pilihTruk(Truk truk) async {
    if (!sudahMasuk ||
        !_setuju ||
        sesiAktif ||
        sibuk ||
        _akunSibuk ||
        truk.vendorId != _supir!.vendor.id ||
        !daftarTruk.contains(truk)) {
      return false;
    }
    return _ubahAkun(() async {
      if (_api case final api?) {
        final id = truk.id;
        if (id == null) {
          throw const KesalahanAkun('Nomor lambung tidak tersedia.');
        }
        await api.pilihTruk(id);
      }
      _truk = truk;
    });
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
      !sibuk &&
      !_akunSibuk;
  Future<bool> mulaiSesi() async {
    if (!bolehMulai) return false;
    _mulai = true;
    _beriTahu();
    try {
      if (_api case final api?) {
        final trukSebelumnya = _truk!.id;
        final terverifikasi = await _ubahAkun(() async {
          _terapkanProfil(await api.periksaSesi());
          if (_truk?.id != trukSebelumnya) {
            _truk = null;
            throw const KesalahanAkun(
              'Penugasan berubah. Pilih kembali nomor lambung Anda.',
            );
          }
        });
        if (!terverifikasi || !_setuju || _dibuang) return false;
      }
      final truk = _truk!;
      await _layanan.mulai(nomorTruk: truk.nomor);
      final dibuat = _layanan.terkini;
      if (dibuat != null) {
        _identitasSesi[dibuat.sessionId] = (
          hp: _kunciHp(_supir!.noHp),
          truk: truk,
        );
      }
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

  List<RingkasanSesi> get riwayat {
    final hp = _supir?.noHp;
    if (hp == null) return const [];
    final kunci = _kunciHp(hp);
    return [
      for (final s in _layanan.riwayat)
        if (_identitasSesi[s.sessionId]?.hp == kunci)
          RingkasanSesi(
            sessionId: s.sessionId,
            truk: _identitasSesi[s.sessionId]!.truk,
            durasi: s.durasi,
            ritase: s.ritase,
            titikTerkirim: s.titikTerkirim,
            pending: s.belumTerkirim,
            mulai: s.mulai,
            selesai: s.waktu,
            otomatis: s.otomatis,
          ),
    ];
  }

  RingkasanSesi? get ringkasanTerakhir => riwayat.lastOrNull;
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
    if (nama == NamaRute.riwayat) return nama;
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
    if (sudahMasuk) await keluar();
    _identitasSesi.clear();
    _tileGagal = false;
    _mulai = false;
    _selesai = false;
    _kesiapan
      ..clear()
      ..addAll(DummyData.kesiapanAwal);
    await _preferensi?.remove(_kunciKesiapan);
    _beriTahu();
  }

  @override
  void dispose() {
    _dibuang = true;
    _langganan.cancel();
    _layanan.dispose();
    _api?.dispose();
    super.dispose();
  }
}
