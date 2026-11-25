import 'package:aplikasi_supir/app/nama_rute.dart';
import 'package:aplikasi_supir/core/widgets/komponen.dart'
    show ChipKesiapan, KartuTruk;
import 'package:aplikasi_supir/data/models/pengaturan_hp.dart';
import 'package:aplikasi_supir/data/services/fake_tracking_service.dart';
import 'package:aplikasi_supir/features/awal/layar_awal.dart';
import 'package:aplikasi_supir/features/beranda/layar_beranda.dart';
import 'package:aplikasi_supir/features/masuk/layar_masuk.dart';
import 'package:aplikasi_supir/features/peta/peta_sesi.dart';
import 'package:aplikasi_supir/features/ringkasan/layar_ringkasan.dart';
import 'package:aplikasi_supir/features/ringkasan/layar_riwayat_sesi.dart';
import 'package:aplikasi_supir/features/sesi_aktif/layar_sesi.dart';
import 'package:aplikasi_supir/main.dart';
import 'package:aplikasi_supir/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:material_ui/material_ui.dart';

import 'app_state_test.dart' show siapkan;

Future<void> tampilkan(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await t.ensureVisible(f);
  await t.pumpAndSettle();
}

Future<void> ketuk(WidgetTester t, String teks) async {
  final f = find.text(teks);
  await tampilkan(t, f);
  await t.tap(f);
  await t.pumpAndSettle();
}

void main() {
  for (final lebar in [360.0, 390.0, 430.0]) {
    for (final skala in [1.0, 1.3]) {
      testWidgets('alur utama, keyboard, sheet, dialog $lebar / $skala', (
        t,
      ) async {
        t.view.physicalSize = Size(lebar, 844);
        t.view.devicePixelRatio = 1;
        t.platformDispatcher.textScaleFactorTestValue = skala;
        t.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(() {
          t.view.resetPhysicalSize();
          t.view.resetDevicePixelRatio();
          t.platformDispatcher.clearTextScaleFactorTestValue();
          t.platformDispatcher.clearAccessibilityFeaturesTestValue();
        });
        final f = FakeTrackingService(
          timerAktif: false,
          pengirim: (b) async => b.map((e) => e.id).toSet(),
        );
        final s = AppState(layanan: f, loginDemo: true)..tileGagal = true;
        addTearDown(s.dispose);
        await t.pumpWidget(AplikasiSupir(state: s));
        await t.pumpAndSettle();
        await ketuk(t, 'Mulai');
        await t.enterText(find.byType(TextFormField).at(0), '0812 3456-7890');
        await t.enterText(find.byType(TextFormField).at(1), '123456');
        expect(
          t
              .widget<TextFormField>(find.byType(TextFormField).at(1))
              .controller!
              .text,
          '123456',
        );
        // Keyboard inset must leave the form scrollable.
        t.view.viewInsets = const FakeViewPadding(bottom: 300);
        await t.pump();
        await ketuk(t, 'Masuk');
        t.view.resetViewInsets();
        await t.pumpAndSettle();
        expect(s.sudahMasuk, isTrue);
        await tampilkan(t, find.byType(CheckboxListTile));
        await t.tap(find.byType(CheckboxListTile));
        await t.pumpAndSettle();
        await ketuk(t, 'Setuju dan lanjut');
        for (final p in PengaturanHp.values.where((p) => !s.siap(p)).toList()) {
          await ketuk(t, p.judul);
          await ketuk(t, 'Simulasikan sudah diatur');
        }
        await ketuk(t, 'Lanjut');
        final sapaan = find.text('Hai, Rahmat');
        expect(sapaan, findsOneWidget);
        expect(
          t.getTopLeft(sapaan).dy,
          greaterThan(
            t.getBottomLeft(find.text('PT. Topabiring Trans Logistik')).dy,
          ),
        );
        await ketuk(t, 'Scan QR · simulasi DT-07');
        expect(find.byType(LayarBeranda), findsOneWidget);
        final header = find.byType(AppBar);
        final keluar = find.text('Keluar');
        expect(keluar, findsOneWidget);
        expect(find.descendant(of: header, matching: keluar), findsOneWidget);
        expect(t.getCenter(keluar).dx, lessThan(t.getCenter(header).dx));
        expect(find.text('Tracker Truk'), findsNothing);
        expect(find.text('PT. Topabiring Trans Logistik'), findsNothing);
        await ketuk(t, 'Ganti');
        await ketuk(t, 'DT-03');
        expect(s.truk!.nomor, 'DT-03');
        await ketuk(t, 'Mulai');
        expect(find.byType(LayarSesi), findsOneWidget);
        final id = s.sesi!.sessionId;
        f.maju();
        await t.pumpAndSettle();
        await ketuk(t, 'Perbesar peta');
        await ketuk(t, 'Lihat seluruh rute');
        final peta = t.state<PetaSesiState>(find.byType(PetaSesi).last);
        expect(peta.mengikuti, isFalse);
        await ketuk(t, 'Ikuti saya');
        expect(peta.mengikuti, isTrue);
        await t.ensureVisible(find.byType(FlutterMap).last);
        await t.drag(find.byType(FlutterMap).last, const Offset(80, 0));
        await t.pumpAndSettle();
        expect(peta.mengikuti, isFalse);
        await ketuk(t, 'Ikuti saya');
        f.maju();
        await t.pumpAndSettle();
        expect(peta.mengikuti, isTrue);
        await t.tap(find.byTooltip('Kembali'));
        await t.pumpAndSettle();
        expect(s.sesi!.sessionId, id);
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(s.sesiAktif, isTrue);
        expect(
          find.text('Gunakan Selesai sesi untuk menghentikan perekaman.'),
          findsOneWidget,
        );
        await t.pump(
          const Duration(seconds: 5),
        ); // snackbar Back selesai tampil
        await t.pumpAndSettle();
        await ketuk(t, 'Selesai sesi');
        await ketuk(t, 'Batal');
        expect(s.sesiAktif, isTrue);
        s.uploadOffline = true;
        s.izinDicabut = true;
        await t.pumpAndSettle();
        expect(find.byType(LayarSesi), findsOneWidget);
        await ketuk(t, 'Selesai sesi');
        await ketuk(t, 'Ya, selesai');
        expect(find.byType(LayarRingkasan), findsOneWidget);
        expect(s.sesiAktif, isFalse);
        expect(s.ringkasanTerakhir!.pending, greaterThan(0));
        await ketuk(t, 'Kembali ke Beranda');
        expect(find.byType(LayarBeranda), findsOneWidget);
        expect(s.pendingLama, greaterThan(0));
        final ringkasan = find.text('Riwayat sesi');
        final kesiapan = find.byType(ChipKesiapan);
        expect(
          t.getCenter(ringkasan).dx,
          greaterThan(t.getCenter(kesiapan).dx),
        );
        expect(
          t.getCenter(ringkasan).dy,
          greaterThan(t.getBottomLeft(find.byType(KartuTruk)).dy),
        );
        await ketuk(t, 'Riwayat sesi');
        expect(find.byType(LayarRiwayatSesi), findsOneWidget);
        await ketuk(t, 'DT-03');
        expect(find.byType(LayarRingkasan), findsOneWidget);
        await t.tap(find.byTooltip('Kembali'));
        await t.pumpAndSettle();
        expect(find.byType(LayarRiwayatSesi), findsOneWidget);
        await t.tap(find.byTooltip('Kembali'));
        await t.pumpAndSettle();
        expect(find.byType(LayarBeranda), findsOneWidget);
        await ketuk(t, 'Keluar');
        expect(find.text('Yakin ingin keluar?'), findsOneWidget);
        expect(s.sudahMasuk, isTrue);
        await ketuk(t, 'Batal');
        expect(find.byType(AlertDialog), findsNothing);
        expect(s.sudahMasuk, isTrue);
        await ketuk(t, 'Keluar');
        await ketuk(t, 'Ya, keluar');
        expect(s.sudahMasuk, isFalse);
        expect(find.byType(FormMasuk), findsOneWidget);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  testWidgets('riwayat mengelompokkan sesi per tanggal mulai WITA', (t) async {
    var jam = DateTime.utc(2026, 11, 24, 15, 59);
    final f = FakeTrackingService(timerAktif: false, jam: () => jam)
      ..uploadOffline = true;
    final s = AppState(layanan: f, loginDemo: true);
    addTearDown(s.dispose);
    await siapkan(s);
    expect(await s.mulaiSesi(), isTrue);
    final idSesiLama = s.sesi!.sessionId;
    f.lompatKe(const Duration(minutes: 2));
    await s.selesaiSesi();
    for (final menit in [5, 10]) {
      jam = DateTime.utc(2026, 11, 24, 16, menit);
      expect(await s.mulaiSesi(), isTrue);
      f.maju();
      await s.selesaiSesi();
    }
    await t.pumpWidget(AplikasiSupir(state: s));
    await t.pumpAndSettle();
    await ketuk(t, 'Riwayat sesi');
    final tanggalTerbaru = find.text('25 November 2026');
    final tanggalLama = find.text('24 November 2026');
    expect(tanggalTerbaru, findsOneWidget);
    expect(tanggalLama, findsOneWidget);
    expect(
      t.getTopLeft(tanggalTerbaru).dy,
      lessThan(t.getTopLeft(tanggalLama).dy),
    );
    expect(find.text('2 sesi · 0 ritase'), findsOneWidget);
    expect(find.text('00.05–00.05 WITA · 0 ret'), findsOneWidget);
    expect(find.text('00.10–00.10 WITA · 0 ret'), findsOneWidget);
    const lintasHari = '23.59–25 November 2026, 00.01 WITA · 0 ret';
    expect(find.text(lintasHari), findsNothing);
    await ketuk(t, '24 November 2026');
    await ketuk(t, lintasHari);
    final detail = t.widget<LayarRingkasan>(find.byType(LayarRingkasan));
    expect(detail.idSesi, idSesiLama);
    expect(find.text('24 November 2026, 23.59 WITA'), findsOneWidget);
    expect(find.text('25 November 2026, 00.01 WITA'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('rute langsung dilindungi dan akhir otomatis dari peta', (
    t,
  ) async {
    final f = FakeTrackingService(timerAktif: false)..uploadOffline = true;
    final s = AppState(layanan: f, loginDemo: true)..tileGagal = true;
    addTearDown(s.dispose);
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.pumpWidget(AplikasiSupir(state: s));
    await t.pumpAndSettle();
    Navigator.of(t.element(find.byType(LayarAwal))).pushNamed(NamaRute.peta);
    await t.pumpAndSettle();
    expect(find.text('Nomor HP'), findsOneWidget);
    final navigator = Navigator.of(t.element(find.byType(FormMasuk)));
    navigator.pop();
    await siapkan(s);
    await s.mulaiSesi();
    await t.pumpAndSettle();
    navigator.pushNamed(NamaRute.peta);
    await t.pumpAndSettle();
    s.lompatKe(const Duration(hours: 16));
    await t.pumpAndSettle();
    expect(find.byType(LayarRingkasan), findsOneWidget);
    expect(s.sesiAktif, isFalse);
    expect(s.ringkasanTerakhir!.otomatis, isTrue);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
  });
}
