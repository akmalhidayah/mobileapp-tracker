import 'package:aplikasi_supir/app/nama_rute.dart';
import 'package:aplikasi_supir/data/dummy/dummy_data.dart';
import 'package:aplikasi_supir/data/models/pengaturan_hp.dart';
import 'package:aplikasi_supir/data/services/fake_tracking_service.dart';
import 'package:aplikasi_supir/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

class GagalMulai extends FakeTrackingService {
  @override
  Future<void> mulai({required String nomorTruk}) async =>
      throw StateError('Gagal mulai dummy');
}

void siapkan(AppState s) {
  s.masuk(noHp: '0812 3456-7890', pin: '123456');
  s.setuju();
  for (final p in PengaturanHp.values) {
    s.tandaiSiap(p);
  }
  s.pilihTruk(DummyData.daftarTruk[1]);
}

void main() {
  test('validasi login langsung, PIN tidak menjadi bagian state', () {
    final s = AppState(layanan: FakeTrackingService(timerAktif: false));
    addTearDown(s.dispose);
    expect(s.masuk(noHp: '081', pin: '123456'), isFalse);
    expect(s.masuk(noHp: '081234567890', pin: 'abcdef'), isFalse);
    expect(s.masuk(noHp: '+62 (812) 3456-7890', pin: '123456'), isTrue);
    expect(s.supir!.noHp, '6281234567890');
  });
  test(
    'guard mulai memeriksa semua prasyarat pada pemanggilan langsung',
    () async {
      final f = FakeTrackingService(timerAktif: false);
      final s = AppState(layanan: f);
      addTearDown(s.dispose);
      expect(await s.mulaiSesi(), isFalse);
      s.masuk(noHp: '081234567890', pin: '123456');
      expect(await s.mulaiSesi(), isFalse);
      s.setuju();
      s.pilihTruk(DummyData.daftarTruk[1]);
      for (final p in PengaturanHp.values.where((p) => !s.siap(p)).toList()) {
        expect(await s.mulaiSesi(), isFalse);
        s.tandaiSiap(p);
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
      expect(s.keluar(), isFalse);
      expect(s.pilihTruk(DummyData.daftarTruk[0]), isFalse);
    },
  );
  test('mulai gagal tidak menyisakan sesi aktif palsu', () async {
    final s = AppState(layanan: GagalMulai());
    addTearDown(s.dispose);
    siapkan(s);
    expect(await s.mulaiSesi(), isFalse);
    expect(s.sesiAktif, isFalse);
    expect(s.sibuk, isFalse);
  });
  test(
    'guard navigasi: deep link, izin dicabut saat aktif, selesai offline',
    () async {
      final f = FakeTrackingService(timerAktif: false);
      final s = AppState(layanan: f);
      addTearDown(s.dispose);
      expect(s.lindungiRute(NamaRute.peta), NamaRute.masuk);
      siapkan(s);
      await s.mulaiSesi();
      s.izinDicabut = true;
      expect(s.ruteSemestinya, NamaRute.sesi);
      expect(s.lindungiRute(NamaRute.kesiapan), NamaRute.sesi);
      expect(s.lindungiRute(NamaRute.peta), NamaRute.peta);
      s.uploadOffline = true;
      await s.selesaiSesi();
      expect(s.ringkasanTerakhir!.pending, 1);
      expect(s.lindungiRute(NamaRute.sesi), NamaRute.ringkasan);
      expect(s.lindungiRute(NamaRute.beranda), NamaRute.beranda);
      expect(s.sesiAktif, isFalse);
    },
  );
  test('reset membersihkan state, persetujuan dan kondisi debug', () async {
    final f = FakeTrackingService(timerAktif: false);
    final s = AppState(layanan: f);
    addTearDown(s.dispose);
    siapkan(s);
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
  test('akun keluar menghapus persetujuan runtime', () {
    final s = AppState(layanan: FakeTrackingService(timerAktif: false));
    addTearDown(s.dispose);
    siapkan(s);
    expect(s.keluar(), isTrue);
    s.masuk(noHp: '081234567891', pin: '654321');
    expect(s.sudahSetuju, isFalse);
  });
}
