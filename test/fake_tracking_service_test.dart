import 'dart:async';

import 'package:aplikasi_supir/core/utils/geo.dart';
import 'package:aplikasi_supir/data/dummy/dummy_data.dart';
import 'package:aplikasi_supir/data/models/area_kerja.dart';
import 'package:aplikasi_supir/data/models/status_perjalanan.dart';
import 'package:aplikasi_supir/data/models/titik_gps.dart';
import 'package:aplikasi_supir/data/services/fake_tracking_service.dart';
import 'package:aplikasi_supir/data/services/mesin_ritase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final awal = DateTime.utc(2026, 11, 17);
  Future<Set<String>> ack(List<TitikGps> batch) async =>
      batch.map((t) => t.id).toSet();
  FakeTrackingService buat({int diam = 5, PengirimDummy? pengirim}) {
    final s = FakeTrackingService(
      jam: () => awal,
      timerAktif: false,
      detikDiam: diam,
      pengirim: pengirim ?? ack,
    );
    addTearDown(s.dispose);
    return s;
  }

  void maju(FakeTrackingService s, int n) {
    for (var i = 0; i < n; i++) {
      s.maju();
    }
  }

  test('geometri fixture: muat, bongkar, dan ruas di luar', () {
    final r = DummyData.ruteHauling.garis;
    expect(titikDalamPoligon(r.first, DummyData.areaMuat.poligon), isTrue);
    expect(titikDalamPoligon(r.last, DummyData.areaBongkar.poligon), isTrue);
    expect(
      titikDalamPoligon(r[r.length ~/ 2], DummyData.areaMuat.poligon),
      isFalse,
    );
  });
  test(
    'siklus valid +1 tepat sekali dan siklus berikutnya 60–90 detik',
    () async {
      final s = buat();
      await s.mulai(nomorTruk: 'DT-07');
      final urutan = [s.status];
      int n = 0;
      while (s.snapshot.ritase == 0 && n < 200) {
        s.maju();
        n++;
        if (urutan.last != s.status) urutan.add(s.status);
      }
      expect(s.snapshot.ritase, 1);
      expect(n, lessThan(90));
      expect(urutan, [
        StatusPerjalanan.kosong,
        StatusPerjalanan.diLoading,
        StatusPerjalanan.bermuatan,
        StatusPerjalanan.diDumping,
        StatusPerjalanan.kosong,
      ]);
      n = 0;
      while (s.snapshot.ritase == 1 && n < 200) {
        s.maju();
        n++;
      }
      expect(s.snapshot.ritase, 2);
      expect(n, inInclusiveRange(60, 90));
    },
  );
  test(
    'melintas cepat tanpa berhenti tidak menghasilkan muatan atau ritase',
    () async {
      final s = buat(diam: 0);
      await s.mulai(nomorTruk: 'DT-07');
      final status = <StatusPerjalanan>{};
      for (var i = 0; i < 300; i++) {
        s.maju();
        status.add(s.status);
      }
      expect(status, contains(StatusPerjalanan.diLoading));
      expect(status, isNot(contains(StatusPerjalanan.bermuatan)));
      expect(s.snapshot.ritase, 0);
    },
  );
  test(
    'rekaman nyata konsisten: 1 detik, seq/timestamp unik, ACK tiap 30 detik',
    () async {
      final s = buat();
      await s.mulai(nomorTruk: 'DT-07');
      maju(s, 29);
      expect(s.snapshot.belumTerkirim, 30);
      expect(s.snapshot.kirimTerakhir, isNull);
      for (var i = 0; i < 30; i++) {
        expect(s.antrean[i].seq, i);
        expect(s.antrean[i].waktu, awal.add(Duration(seconds: i)));
      }
      s.maju();
      await s.kirimSekarang();
      expect(s.snapshot.belumTerkirim, 0);
      expect(s.snapshot.titikTerkirim, 31);
      maju(s, 6);
      expect(s.snapshot.belumTerkirim, 6);
      await s.kirimSekarang();
      expect(s.snapshot.totalRekaman, 37);
      expect(s.snapshot.titikTerkirim, 37);
    },
  );
  test('maju sebelum mulai, setelah selesai/dispose tidak merekam', () async {
    final s = buat();
    maju(s, 10);
    expect(s.terkini, isNull);
    expect(s.antrean, isEmpty);
    await s.mulai(nomorTruk: 'DT-07');
    maju(s, 2);
    await s.selesai();
    final akhir = s.snapshot;
    maju(s, 10);
    expect(s.snapshot.totalRekaman, akhir.totalRekaman);
    expect(s.snapshot.durasi, akhir.durasi);
    s.dispose();
    maju(s, 10);
    expect(s.snapshot.durasi, akhir.durasi);
  });
  test(
    'GPS mati dan izin dicabut menghentikan rekaman, durasi lanjut, seq pulih',
    () async {
      final s = buat();
      await s.mulai(nomorTruk: 'DT-07');
      maju(s, 2);
      final last = s.snapshot.posisi!;
      s.simulasiGpsMati = true;
      maju(s, 5);
      expect(s.snapshot.posisi, same(last));
      s.simulasiGpsMati = false;
      s.izinDicabut = true;
      maju(s, 5);
      expect(s.snapshot.posisi, same(last));
      expect(s.snapshot.durasi, const Duration(seconds: 12));
      s.izinDicabut = false;
      s.maju();
      expect(s.snapshot.posisi!.seq, last.seq + 1);
      expect(s.snapshot.perluDicek, isTrue);
    },
  );
  test('pending tidak dipangkas bersama jejak 200 titik', () async {
    final s = buat()..uploadOffline = true;
    await s.mulai(nomorTruk: 'DT-07');
    maju(s, 260);
    expect(s.snapshot.jejak, hasLength(200));
    expect(s.antrean, hasLength(261));
    expect(s.snapshot.jejak.last.seq, 260);
    expect(s.snapshot.totalRekaman, 261);
  });
  test('offline selesai langsung menghentikan rekaman; retry tidak menyalakan sesi', () async {
    final s = buat()..uploadOffline = true;
    await s.mulai(nomorTruk: 'DT-07');
    maju(s, 4);
    final akhir = s.selesai();
    expect(s.berjalan, isFalse);
    s.maju();
    await akhir;
    expect(s.snapshot.belumTerkirim, 5);
    expect(s.snapshot.titikTerkirim, 0);
    s.uploadOffline = false;
    await s.kirimSekarang();
    await s.kirimSekarang();
    expect(s.snapshot.titikTerkirim, 5);
    expect(s.snapshot.belumTerkirim, 0);
    expect(s.berjalan, isFalse);
  });
  test('ACK parsial dan paralel hanya menghapus batch yang diakui', () async {
    final balasan = Completer<Set<String>>();
    List<TitikGps> batch = [];
    int panggilan = 0;
    final s = buat(
      pengirim: (b) {
        batch = b;
        panggilan++;
        return balasan.future;
      },
    );
    await s.mulai(nomorTruk: 'DT-07');
    maju(s, 2);
    final a = s.kirimSekarang(), b = s.kirimSekarang();
    expect(identical(a, b), isTrue);
    expect(panggilan, 1);
    s.maju();
    balasan.complete({batch.first.id, 'palsu:999'});
    await a;
    expect(s.snapshot.titikTerkirim, 1);
    expect(s.snapshot.belumTerkirim, 3);
    expect(s.antrean.last.seq, 3);
  });
  test(
    'pending sesi lama tetap terikat sesi asal saat sesi baru dimulai',
    () async {
      final s = buat()..uploadOffline = true;
      await s.mulai(nomorTruk: 'DT-07');
      maju(s, 2);
      await s.selesai();
      final id = s.snapshot.sessionId;
      await s.mulai(nomorTruk: 'DT-03');
      expect(s.snapshot.sessionId, isNot(id));
      expect(s.snapshot.posisi!.seq, 0);
      expect(s.riwayat.single.belumTerkirim, 3);
      expect(s.snapshot.belumTerkirim, 1);
      s.uploadOffline = false;
      await s.kirimSekarang();
      expect(s.riwayat.single.titikTerkirim, 3);
      expect(s.snapshot.titikTerkirim, 1);
    },
  );
  test(
    'mulai dan selesai berulang tidak membuat sesi atau ACK ganda',
    () async {
      final s = buat();
      await s.mulai(nomorTruk: 'DT-07');
      final id = s.snapshot.sessionId;
      await s.mulai(nomorTruk: 'DT-03');
      expect(s.snapshot.sessionId, id);
      expect(s.snapshot.nomorTruk, 'DT-07');
      await Future.wait([s.selesai(), s.selesai()]);
      expect(s.riwayat, hasLength(1));
      expect(s.snapshot.titikTerkirim, 1);
    },
  );
  test('batas 12/16 jam, jeda data dan akhir otomatis offline', () async {
    final s = buat()..uploadOffline = true;
    await s.mulai(nomorTruk: 'DT-07');
    s.lompatKe(const Duration(hours: 12) - const Duration(seconds: 1));
    expect(s.snapshot.pengingat12Jam, isFalse);
    s.maju();
    expect(s.snapshot.pengingat12Jam, isTrue);
    s.lompatKe(const Duration(hours: 12));
    s.lompatKe(const Duration(hours: 16) - const Duration(seconds: 1));
    final n = s.snapshot.totalRekaman;
    s.maju();
    expect(s.berjalan, isFalse);
    expect(s.snapshot.otomatis, isTrue);
    expect(s.snapshot.totalRekaman, n);
    maju(s, 10);
    expect(s.snapshot.durasi, const Duration(hours: 16));
    expect(s.snapshot.belumTerkirim, n);
  });
  test('reset membatalkan efek ACK yang datang terlambat', () async {
    final c = Completer<Set<String>>();
    List<TitikGps> batch = [];
    final s = buat(
      pengirim: (b) {
        batch = b;
        return c.future;
      },
    );
    await s.mulai(nomorTruk: 'DT-07');
    final f = s.kirimSekarang();
    await s.reset();
    await s.mulai(nomorTruk: 'DT-03');
    c.complete(batch.map((t) => t.id).toSet());
    await f;
    expect(s.snapshot.belumTerkirim, 1);
    expect(s.snapshot.titikTerkirim, 0);
    expect(s.riwayat, isEmpty);
  });
  testWidgets('timer tunggal, 5× dan dispose', (tester) async {
    final s = FakeTrackingService(jam: () => awal, pengirim: ack)
      ..percepatan = 5;
    await s.mulai(nomorTruk: 'DT-07');
    await s.mulai(nomorTruk: 'DT-07');
    await tester.pump(const Duration(seconds: 2));
    expect(s.snapshot.durasi, const Duration(seconds: 10));
    await s.selesai();
    await tester.pump(const Duration(seconds: 2));
    expect(s.snapshot.durasi, const Duration(seconds: 10));
    s.dispose();
  });

  group('MesinRitase', () {
    final rute = DummyData.ruteHauling.garis;
    final muat = rute.first,
        jalan = rute[rute.length ~/ 2],
        bongkar = rute.last;
    MesinRitase mesin({Duration? minimum}) => MesinRitase(
      areaMuat: minimum == null
          ? DummyData.areaMuat
          : AreaKerja(
              nama: 'Muat',
              jenis: JenisArea.muat,
              poligon: DummyData.areaMuat.poligon,
              durasiMinimum: minimum,
            ),
      areaBongkar: DummyData.areaBongkar,
    );
    DateTime t(int n) => awal.add(Duration(seconds: n));
    void keluar(MesinRitase m, int n) {
      m.proses(jalan, t(n));
      m.proses(jalan, t(n + 1));
    }

    void muatValid(MesinRitase m) {
      m.proses(muat, t(0));
      m.proses(muat, t(4));
      keluar(m, 5);
    }

    test('durasi timestamp: 4 titik 30 detik baru 90 detik', () {
      final m = mesin(minimum: const Duration(minutes: 2));
      for (final n in [0, 30, 60, 90]) {
        m.proses(muat, t(n));
      }
      keluar(m, 91);
      expect(m.status, StatusPerjalanan.kosong);
      final valid = mesin(minimum: const Duration(minutes: 2));
      for (final n in [0, 30, 60, 90, 120]) {
        valid.proses(muat, t(n));
      }
      keluar(valid, 121);
      expect(valid.status, StatusPerjalanan.bermuatan);
    });
    test('bongkar tanpa muat ditandai, tidak dihitung', () {
      final m = mesin();
      m.proses(bongkar, t(0));
      m.proses(bongkar, t(5));
      keluar(m, 6);
      expect(m.ritase, 0);
      expect(m.perluDicek, isTrue);
    });
    test('batal muat kembali loading menghapus muatan lama', () {
      final m = mesin();
      muatValid(m);
      m.proses(muat, t(8));
      keluar(m, 9);
      m.proses(bongkar, t(12));
      m.proses(bongkar, t(17));
      keluar(m, 18);
      expect(m.ritase, 0);
    });
    test('akurasi >30m tidak boleh menentukan masuk atau keluar', () {
      final m = mesin();
      m.proses(muat, t(0), akurasi: 31);
      expect(m.status, StatusPerjalanan.kosong);
      m.proses(muat, t(1));
      m.proses(muat, t(5));
      m.proses(jalan, t(6), akurasi: 40);
      keluar(m, 7);
      expect(m.status, StatusPerjalanan.kosong);
      expect(m.perluDicek, isTrue);
    });
    test('bergerak atau jeda data tidak dihitung sebagai dwell', () {
      final m = mesin();
      m.proses(muat, t(0), kecepatan: 8);
      m.proses(muat, t(5), kecepatan: 8);
      keluar(m, 6);
      expect(m.status, StatusPerjalanan.kosong);
      m.proses(muat, t(10));
      m.proses(muat, t(100));
      keluar(m, 101);
      expect(m.status, StatusPerjalanan.kosong);
    });
    test(
      'jitter satu titik dan snapshot berulang tidak menggandakan ritase',
      () {
        final m = mesin();
        muatValid(m);
        m.proses(bongkar, t(10));
        m.proses(bongkar, t(14));
        m.proses(jalan, t(15));
        expect(m.ritase, 0);
        m.proses(bongkar, t(16));
        m.proses(jalan, t(17));
        m.proses(jalan, t(17));
        expect(m.ritase, 0);
        m.proses(jalan, t(18));
        expect(m.ritase, 1);
        m.proses(jalan, t(18));
        m.proses(jalan, t(19));
        expect(m.ritase, 1);
      },
    );
    test('singgah dumping terlalu singkat tidak dihitung', () {
      final m = mesin();
      muatValid(m);
      m.proses(bongkar, t(10));
      keluar(m, 11);
      expect(m.ritase, 0);
      expect(m.status, StatusPerjalanan.bermuatan);
    });
  });
}
