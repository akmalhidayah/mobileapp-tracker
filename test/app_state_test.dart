import 'dart:convert';

import 'package:aplikasi_supir/app/nama_rute.dart';
import 'package:aplikasi_supir/data/dummy/dummy_data.dart';
import 'package:aplikasi_supir/data/models/pengaturan_hp.dart';
import 'package:aplikasi_supir/data/services/akun_sopir_api.dart';
import 'package:aplikasi_supir/data/services/fake_tracking_service.dart';
import 'package:aplikasi_supir/state/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class GagalMulai extends FakeTrackingService {
  @override
  Future<void> mulai({required String nomorTruk}) async =>
      throw StateError('Gagal mulai dummy');
}

Future<void> siapkan(AppState s) async {
  await s.masuk(noHp: '0812 3456-7890', pin: '123456');
  await s.setuju();
  for (final p in PengaturanHp.values) {
    await s.tandaiSiap(p);
  }
  await s.pilihTruk(DummyData.daftarTruk[1]);
}

void main() {
  test('tanpa konfigurasi API, akun demo tidak dapat digunakan', () async {
    final s = AppState(layanan: FakeTrackingService(timerAktif: false));
    addTearDown(s.dispose);
    expect(s.loginTersedia, isFalse);
    expect(await s.masuk(noHp: '081234567890', pin: '123456'), isFalse);
    expect(s.pesanAkun, contains('Server login belum dikonfigurasi'));
  });

  test('alamat debug memakai Django lokal dan menerima IP privat di iOS', () {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(AkunSopirApi.alamatServer('')!.host, '10.0.2.2');
    expect(AkunSopirApi.alamatServer('http://192.168.1.10:8001'), isNull);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(AkunSopirApi.alamatServer('')!.host, '127.0.0.1');
    expect(AkunSopirApi.alamatServer('http://192.168.1.10:8001')!.port, 8001);
    expect(AkunSopirApi.alamatServer('http://example.com'), isNull);
    expect(AkunSopirApi.alamatServer('https://example.com')!.scheme, 'https');
    expect(AkunSopirApi.alamatServer('https://example.com/subfolder'), isNull);
  });

  test('validasi login langsung, PIN tidak menjadi bagian state', () async {
    final s = AppState(
      layanan: FakeTrackingService(timerAktif: false),
      loginDemo: true,
    );
    addTearDown(s.dispose);
    expect(await s.masuk(noHp: '081', pin: '123456'), isFalse);
    expect(await s.masuk(noHp: '081234567890', pin: 'abcdef'), isFalse);
    expect(await s.masuk(noHp: '+62 (812) 3456-7890', pin: '123456'), isTrue);
    expect(s.supir!.noHp, '6281234567890');
  });
  test(
    'guard mulai memeriksa semua prasyarat pada pemanggilan langsung',
    () async {
      final f = FakeTrackingService(timerAktif: false);
      final s = AppState(layanan: f, loginDemo: true);
      addTearDown(s.dispose);
      expect(await s.mulaiSesi(), isFalse);
      await s.masuk(noHp: '081234567890', pin: '123456');
      expect(await s.mulaiSesi(), isFalse);
      await s.setuju();
      await s.pilihTruk(DummyData.daftarTruk[1]);
      for (final p in PengaturanHp.values.where((p) => !s.siap(p)).toList()) {
        expect(await s.mulaiSesi(), isFalse);
        await s.tandaiSiap(p);
      }
      s.simulasiGpsMati = true;
      expect(await s.mulaiSesi(), isFalse);
      s.simulasiGpsMati = false;
      s.izinDicabut = true;
      expect(await s.mulaiSesi(), isFalse);
      s.izinDicabut = false;
      final mulai = s.mulaiSesi();
      expect(await s.mulaiSesi(), isFalse);
      expect(await mulai, isTrue);
      expect(await s.keluar(), isFalse);
      expect(await s.pilihTruk(DummyData.daftarTruk[0]), isFalse);
    },
  );
  test('mulai gagal tidak menyisakan sesi aktif palsu', () async {
    final s = AppState(layanan: GagalMulai(), loginDemo: true);
    addTearDown(s.dispose);
    await siapkan(s);
    expect(await s.mulaiSesi(), isFalse);
    expect(s.sesiAktif, isFalse);
    expect(s.sibuk, isFalse);
  });
  test(
    'guard navigasi: deep link, izin dicabut saat aktif, selesai offline',
    () async {
      final f = FakeTrackingService(timerAktif: false);
      final s = AppState(layanan: f, loginDemo: true);
      addTearDown(s.dispose);
      expect(s.lindungiRute(NamaRute.peta), NamaRute.masuk);
      expect(s.lindungiRute(NamaRute.riwayat), NamaRute.masuk);
      await siapkan(s);
      await s.mulaiSesi();
      s.izinDicabut = true;
      expect(s.ruteSemestinya, NamaRute.sesi);
      expect(s.lindungiRute(NamaRute.kesiapan), NamaRute.sesi);
      expect(s.lindungiRute(NamaRute.peta), NamaRute.peta);
      expect(s.lindungiRute(NamaRute.riwayat), NamaRute.sesi);
      s.uploadOffline = true;
      await s.selesaiSesi();
      expect(s.ringkasanTerakhir!.pending, 1);
      expect(s.lindungiRute(NamaRute.sesi), NamaRute.ringkasan);
      expect(s.lindungiRute(NamaRute.beranda), NamaRute.beranda);
      expect(s.lindungiRute(NamaRute.riwayat), NamaRute.riwayat);
      expect(s.sesiAktif, isFalse);
    },
  );
  test('reset membersihkan state, persetujuan dan kondisi debug', () async {
    final f = FakeTrackingService(timerAktif: false);
    final s = AppState(layanan: f, loginDemo: true);
    addTearDown(s.dispose);
    await siapkan(s);
    await s.mulaiSesi();
    s.simulasiGpsMati = true;
    s.tileGagal = true;
    s.uploadOffline = true;
    s.charging = false;
    s.baterai = 10;
    await s.resetSemua();
    expect(s.sudahMasuk, isFalse);
    expect(s.sudahSetuju, isFalse);
    expect(s.truk, isNull);
    expect(s.sesiAktif, isFalse);
    expect(s.sesi, isNull);
    expect(s.riwayat, isEmpty);
    expect(s.jumlahSiap, 2);
    expect(s.tileGagal, isFalse);
    expect(s.uploadOffline, isFalse);
    expect(s.charging, isTrue);
    expect(s.baterai, 72);
  });
  test('akun keluar menghapus persetujuan runtime', () async {
    final s = AppState(
      layanan: FakeTrackingService(timerAktif: false),
      loginDemo: true,
    );
    addTearDown(s.dispose);
    await siapkan(s);
    expect(await s.keluar(), isTrue);
    await s.masuk(noHp: '081234567891', pin: '123456');
    expect(s.sudahSetuju, isFalse);
  });

  test('login pulih tanpa PIN, persetujuan tetap berlaku, dan penugasan dicek ulang', () async {
    FlutterSecureStorage.setMockInitialValues({});
    var setuju = false, tersambung = true, tokenBerlaku = true;
    var berlakuTruk = true;
    int? trukTerpilihId;
    var jumlahLogin = 0;

    Map<String, Object?> profil() => {
      'pengemudi': {'nama': 'Sopir uji', 'nomor_hp': '+6281234567890'},
      'ekspeditur': {'id': 5, 'nama': 'Ekspeditur uji', 'nama_singkat': 'Uji'},
      'versi_persetujuan': versiPersetujuanSopir,
      'sudah_setuju': setuju,
      'truk_terpilih_id': berlakuTruk ? trukTerpilihId : null,
      'truk': [
        if (berlakuTruk)
          {'id': 51, 'nomor_lambung': 'UJI-51', 'kapasitas_ton': '28.50'},
      ],
    };

    AppState aplikasiBaru() {
      final state = AppState(
        layanan: FakeTrackingService(timerAktif: false),
        apiAkun: AkunSopirApi(
          alamat: Uri.parse('https://tracker.example'),
          instalasi: () async => 'instalasi-uji',
          penyimpanan: const FlutterSecureStorage(),
          klien: MockClient((request) async {
            final tujuan = request.url.pathSegments[3];
            final data = jsonDecode(request.body) as Map<String, dynamic>;
            if (!tersambung) return http.Response('{}', 503);
            if (tujuan == 'login') {
              if (data['pin'] != '023456') return http.Response('{}', 401);
              jumlahLogin++;
              tokenBerlaku = true;
              return http.Response(
                jsonEncode({'token': 'token-uji', ...profil()}),
                200,
              );
            }
            expect(request.headers['Authorization'], 'Bearer token-uji');
            if (!tokenBerlaku) return http.Response('{}', 401);
            switch (tujuan) {
              case 'consent':
                expect(data['versi'], versiPersetujuanSopir);
                setuju = true;
              case 'selected-truck':
                trukTerpilihId = data['truk_id'] as int;
              case 'logout':
                tokenBerlaku = false;
              case 'session':
                return http.Response(jsonEncode(profil()), 200);
              default:
                fail('Endpoint tak terduga: $tujuan');
            }
            return http.Response('', 204);
          }),
        ),
      );
      addTearDown(state.dispose);
      return state;
    }

    final s = aplikasiBaru();
    expect(await s.masuk(noHp: '081234567890', pin: '123456'), isFalse);
    expect(await s.masuk(noHp: '081234567890', pin: '023456'), isTrue);
    expect(s.ruteSemestinya, NamaRute.persetujuan);
    expect(s.daftarTruk.map((truk) => truk.nomor), ['UJI-51']);
    expect(await s.setuju(), isTrue);
    for (final p in PengaturanHp.values) {
      await s.tandaiSiap(p);
    }
    expect(await s.pilihTruk(s.daftarTruk.single), isTrue);
    expect(await s.mulaiSesi(), isTrue);
    await s.selesaiSesi();
    expect(s.ringkasanTerakhir!.truk.kapasitasTon, 28.5);

    final besok = aplikasiBaru();
    tersambung = false;
    expect(await besok.pulihkanLogin(), isFalse);
    tersambung = true;
    expect(await besok.pulihkanLogin(), isTrue);
    expect(jumlahLogin, 1);
    expect(besok.ruteSemestinya, NamaRute.beranda);
    expect(besok.sudahSetuju, isTrue);
    expect(besok.truk?.nomor, 'UJI-51');
    expect(besok.sesiAktif, isFalse);
    for (final p in PengaturanHp.values) {
      await besok.tandaiSiap(p);
    }
    berlakuTruk = false;
    expect(await besok.mulaiSesi(), isFalse);
    expect(besok.ruteSemestinya, NamaRute.pilihTruk);

    expect(await besok.keluar(), isTrue);
    tokenBerlaku = true;
    final setelahKeluar = aplikasiBaru();
    expect(await setelahKeluar.pulihkanLogin(), isTrue);
    expect(setelahKeluar.sudahMasuk, isFalse);
    expect(
      await setelahKeluar.masuk(noHp: '081234567890', pin: '023456'),
      isTrue,
    );
    expect(setelahKeluar.sudahSetuju, isTrue);

    tokenBerlaku = false;
    final kedaluwarsa = aplikasiBaru();
    expect(await kedaluwarsa.pulihkanLogin(), isTrue);
    expect(kedaluwarsa.sudahMasuk, isFalse);
  });
}
