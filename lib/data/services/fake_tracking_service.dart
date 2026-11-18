import 'dart:async';
import 'dart:math' as math;

import '../../core/utils/geo.dart';
import '../dummy/dummy_data.dart';
import '../models/area_kerja.dart';
import '../models/rute.dart';
import '../models/snapshot_sesi.dart';
import '../models/status_perjalanan.dart';
import '../models/titik_gps.dart';
import 'konfigurasi_simulasi.dart';
import 'mesin_ritase.dart';
import 'tracking_service.dart';

typedef PengirimDummy = Future<Set<String>> Function(List<TitikGps> batch);

class FakeTrackingService implements TrackingService, KendaliSimulasi {
  FakeTrackingService({
    Rute? rute,
    AreaKerja? areaMuat,
    AreaKerja? areaBongkar,
    this.detikDiam = 5,
    this.detikSekaliJalan = 32,
    DateTime Function()? jam,
    this.timerAktif = true,
    this.konfigurasi = KonfigurasiSimulasi.demo,
    PengirimDummy? pengirim,
  }) : _jam = jam ?? DateTime.now,
       _pengirim = pengirim ?? _ackDemo {
    _lintasan = Lintasan((rute ?? DummyData.ruteHauling).garis);
    _mesin = MesinRitase(
      areaMuat: areaMuat ?? DummyData.areaMuat,
      areaBongkar: areaBongkar ?? DummyData.areaBongkar,
      jedaMaksimum: konfigurasi.rekam * 2,
    );
  }
  static Future<Set<String>> _ackDemo(List<TitikGps> batch) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return batch.map((e) => e.id).toSet();
  }

  final int detikDiam, detikSekaliJalan;
  final bool timerAktif;
  final KonfigurasiSimulasi konfigurasi;
  final DateTime Function() _jam;
  final PengirimDummy _pengirim;
  late final Lintasan _lintasan;
  late final MesinRitase _mesin;
  final _pengendali = StreamController<SnapshotSesi>.broadcast(sync: true);
  final Map<String, TitikGps> _pending = {};
  final Set<String> _ack = {};
  final Map<String, SnapshotSesi> _arsip = {};
  final Map<String, DateTime> _waktuAck = {};
  final List<TitikGps> _jejak = [];
  Timer? _timer;
  Future<void>? _pengiriman;
  bool _aktif = false, _dibuang = false, _gpsMati = false, _izinDicabut = false;
  bool _offline = false,
      _gagalUpload = false,
      _gagalKirim = false,
      _charging = true;
  bool _otomatis = false, _pengingat = false;
  int _baterai = 72,
      _percepatan = 1,
      _detik = 0,
      _seq = 0,
      _nomorSesi = 0,
      _generasi = 0;
  String _sessionId = '', _nomorTruk = '';
  DateTime _mulaiPada = DateTime.fromMillisecondsSinceEpoch(0);
  double _meter = 0, _arah = 0;
  bool _menujuBongkar = false;
  int _sisaDiam = 0;
  TitikGps? _posisi;
  bool get berjalan => _aktif;
  DateTime get _sekarang => _mulaiPada.add(Duration(seconds: _detik));
  StatusPerjalanan get status => _mesin.status;
  List<TitikGps> get antrean => List.unmodifiable(_pending.values);
  @override
  Stream<SnapshotSesi> get perubahan => _pengendali.stream;
  @override
  SnapshotSesi? get terkini => _sessionId.isEmpty ? null : snapshot;
  @override
  List<SnapshotSesi> get riwayat => [
    for (final s in _arsip.values) _salinHitungan(s),
    if (_sessionId.isNotEmpty && !_aktif) snapshot,
  ];
  int _pendingUntuk(String id) =>
      _pending.values.where((e) => e.sessionId == id).length;
  int _ackUntuk(String id) => _ack.where((e) => e.startsWith('$id:')).length;
  SnapshotSesi _salinHitungan(SnapshotSesi s) => SnapshotSesi(
    sessionId: s.sessionId,
    nomorTruk: s.nomorTruk,
    waktu: s.waktu,
    durasi: s.durasi,
    posisi: s.posisi,
    jejak: s.jejak,
    status: s.status,
    ritase: s.ritase,
    belumTerkirim: _pendingUntuk(s.sessionId),
    titikTerkirim: _ackUntuk(s.sessionId),
    kirimTerakhir: _waktuAck[s.sessionId],
    gpsAktif: s.gpsAktif,
    baterai: s.baterai,
    sedangDicas: s.sedangDicas,
    izinLokasi: s.izinLokasi,
    otomatis: s.otomatis,
    pengingat12Jam: s.pengingat12Jam,
    perluDicek: s.perluDicek,
    sedangKirim: _pengiriman != null,
    gagalKirim: _gagalKirim,
  );
  SnapshotSesi get snapshot => SnapshotSesi(
    sessionId: _sessionId,
    nomorTruk: _nomorTruk,
    aktif: _aktif,
    waktu: _sekarang,
    durasi: Duration(seconds: _detik),
    posisi: _posisi,
    jejak: List.unmodifiable(_jejak),
    status: _mesin.status,
    ritase: _mesin.ritase,
    belumTerkirim: _pendingUntuk(_sessionId),
    titikTerkirim: _ackUntuk(_sessionId),
    kirimTerakhir: _waktuAck[_sessionId],
    gpsAktif: !_gpsMati,
    izinLokasi: !_izinDicabut,
    baterai: _baterai,
    sedangDicas: _charging,
    sedangKirim: _pengiriman != null,
    gagalKirim: _gagalKirim,
    pengingat12Jam: _pengingat,
    otomatis: _otomatis,
    perluDicek: _mesin.perluDicek,
  );
  void _pancarkan() {
    if (!_dibuang && _sessionId.isNotEmpty) _pengendali.add(snapshot);
  }

  @override
  bool get simulasiGpsMati => _gpsMati;
  @override
  set simulasiGpsMati(bool v) {
    if (v == _gpsMati) return;
    _gpsMati = v;
    if (v && _aktif) _mesin.dataHilang();
    _pancarkan();
  }

  @override
  bool get izinDicabut => _izinDicabut;
  @override
  set izinDicabut(bool v) {
    if (v == _izinDicabut) return;
    _izinDicabut = v;
    if (v && _aktif) _mesin.dataHilang();
    _pancarkan();
  }

  @override
  bool get uploadOffline => _offline;
  @override
  set uploadOffline(bool v) {
    _offline = v;
    _pancarkan();
  }

  @override
  bool get gagalUpload => _gagalUpload;
  @override
  set gagalUpload(bool v) {
    _gagalUpload = v;
    _pancarkan();
  }

  @override
  int get baterai => _baterai;
  @override
  set baterai(int v) {
    _baterai = v.clamp(0, 100);
    _pancarkan();
  }

  @override
  bool get charging => _charging;
  @override
  set charging(bool v) {
    _charging = v;
    _pancarkan();
  }

  @override
  int get percepatan => _percepatan;
  @override
  set percepatan(int v) {
    _percepatan = v == 5 ? 5 : 1;
    if (_aktif) _pasangTimer();
  }

  void _pasangTimer() {
    _timer?.cancel();
    if (timerAktif) {
      _timer = Timer.periodic(
        Duration(milliseconds: 1000 ~/ _percepatan),
        (_) => maju(),
      );
    }
  }

  @override
  Future<void> mulai({required String nomorTruk}) async {
    if (_dibuang) throw StateError('Layanan sudah ditutup');
    if (_aktif) return;
    if (_gpsMati || _izinDicabut) throw StateError('Lokasi belum siap');
    if (_sessionId.isNotEmpty) _arsip[_sessionId] = snapshot;
    final jam = _jam();
    final mulai = jam.isBefore(_sekarang) ? _sekarang : jam;
    _sessionId = 'demo-${++_nomorSesi}';
    _nomorTruk = nomorTruk;
    _mulaiPada = mulai;
    _detik = 0;
    _seq = 0;
    _meter = _lintasan.panjang * 0.3;
    _menujuBongkar = false;
    _sisaDiam = 0;
    _arah = (_lintasan.arahPada(_meter) + 180) % 360;
    _jejak.clear();
    _posisi = null;
    _otomatis = false;
    _pengingat = false;
    _mesin.reset();
    _aktif = true;
    _rekam(0);
    _pasangTimer();
    _pancarkan();
  }

  /// Satu detik virtual. Perekaman hanya saat sesi aktif dan lokasi tersedia.
  void maju() {
    if (!_aktif || _dibuang) return;
    _detik++;
    if (_detik >= konfigurasi.batas.inSeconds) {
      _otomatis = true;
      unawaited(selesai());
      return;
    }
    if (_detik >= konfigurasi.pengingat.inSeconds) _pengingat = true;
    final kecepatan = _gerak();
    if (!_gpsMati &&
        !_izinDicabut &&
        _detik % konfigurasi.rekam.inSeconds == 0) {
      _rekam(kecepatan);
    }
    if (_detik % konfigurasi.upload.inSeconds == 0) unawaited(kirimSekarang());
    _pancarkan();
  }

  @override
  void lompatKe(Duration durasi) {
    if (!_aktif || _dibuang || durasi.inSeconds <= _detik) return;
    // Lompatan debug bukan rekaman GPS ribuan jam: tandai data hilang.
    _mesin.dataHilang();
    _detik = math.min(durasi.inSeconds, konfigurasi.batas.inSeconds);
    if (_detik >= konfigurasi.pengingat.inSeconds) _pengingat = true;
    if (_detik >= konfigurasi.batas.inSeconds) {
      _otomatis = true;
      unawaited(selesai());
    } else {
      _pancarkan();
    }
  }

  double _gerak() {
    if (_sisaDiam > 0) {
      _sisaDiam--;
      return 0;
    }
    _meter += (_menujuBongkar ? 1 : -1) * _lintasan.panjang / detikSekaliJalan;
    final sampai = _menujuBongkar ? _meter >= _lintasan.panjang : _meter <= 0;
    if (sampai) {
      _meter = _menujuBongkar ? _lintasan.panjang : 0;
      _menujuBongkar = !_menujuBongkar;
      _sisaDiam = detikDiam;
    }
    final maju = sampai ? !_menujuBongkar : _menujuBongkar;
    _arah = (_lintasan.arahPada(_meter) + (maju ? 0 : 180)) % 360;
    return (32 + 4 * math.sin(_detik / 4)) /
        3.6; // kecepatan contoh, bukan pengukuran fisik
  }

  void _rekam(double kecepatan) {
    final p = _lintasan.posisiPada(_meter);
    final t = TitikGps(
      lat: p.latitude,
      lon: p.longitude,
      akurasi: 6 + 2 * math.sin(_detik / 7),
      kecepatan: kecepatan,
      arah: _arah,
      waktu: _sekarang,
      seq: _seq++,
      sessionId: _sessionId,
    );
    _posisi = t;
    _pending[t.id] = t;
    _jejak.add(t);
    if (_jejak.length > SnapshotSesi.maksJejak) _jejak.removeAt(0);
    _mesin.proses(
      t.posisi,
      t.waktu,
      akurasi: t.akurasi,
      kecepatan: t.kecepatan,
    );
  }

  @override
  Future<void> kirimSekarang() {
    if (_dibuang) return Future.value();
    if (_pengiriman != null) return _pengiriman!;
    if (_pending.isEmpty) return Future.value();
    final completer = Completer<void>();
    _pengiriman = completer.future;
    final generasi = _generasi;
    final batch = List<TitikGps>.unmodifiable(_pending.values);
    final waktuAck = _sekarang;
    _gagalKirim = false;
    _pancarkan();
    () async {
      try {
        if (_offline || _gagalUpload) {
          throw StateError('Pengiriman simulasi gagal');
        }
        final ids = await _pengirim(batch);
        if (_dibuang || generasi != _generasi) return;
        // ACK hanya berlaku untuk batch yang benar-benar dikirim.
        for (final t in batch) {
          if (ids.contains(t.id)) {
            _pending.remove(t.id);
            _ack.add(t.id);
            _waktuAck[t.sessionId] = waktuAck;
          }
        }
        _gagalKirim = batch.any((e) => !ids.contains(e.id));
      } catch (_) {
        if (!_dibuang && generasi == _generasi) _gagalKirim = true;
      } finally {
        if (generasi == _generasi) {
          _pengiriman = null;
          _pancarkan();
        }
        completer.complete();
      }
    }();
    return completer.future;
  }

  @override
  Future<void> selesai() async {
    if (!_aktif || _dibuang) return;
    final generasi = _generasi;
    final id = _sessionId;
    _aktif = false;
    _timer?.cancel();
    _timer = null;
    _pancarkan();
    await kirimSekarang();
    // Jika batch sebelumnya sedang berjalan, kirim sisa rekaman di akhir.
    if (!_dibuang &&
        generasi == _generasi &&
        id == _sessionId &&
        !_gagalKirim &&
        _pending.isNotEmpty) {
      await kirimSekarang();
    }
  }

  @override
  Future<void> reset() async {
    _generasi++;
    _timer?.cancel();
    _timer = null;
    _aktif = false;
    _pengiriman = null;
    _pending.clear();
    _ack.clear();
    _arsip.clear();
    _waktuAck.clear();
    _jejak.clear();
    _sessionId = '';
    _mulaiPada = DateTime.fromMillisecondsSinceEpoch(0);
    _posisi = null;
    _seq = 0;
    _detik = 0;
    _gpsMati = false;
    _izinDicabut = false;
    _offline = false;
    _gagalUpload = false;
    _gagalKirim = false;
    _charging = true;
    _baterai = 72;
    _percepatan = 1;
    _otomatis = false;
    _pengingat = false;
    _mesin.reset();
  }

  @override
  void dispose() {
    if (_dibuang) return;
    _dibuang = true;
    _generasi++;
    _aktif = false;
    _timer?.cancel();
    _timer = null;
    _pengendali.close();
  }
}
