import 'package:aplikasi_supir/app/nama_rute.dart';
import 'package:aplikasi_supir/core/widgets/komponen.dart';
import 'package:aplikasi_supir/data/models/pengaturan_hp.dart';
import 'package:aplikasi_supir/data/services/fake_tracking_service.dart';
import 'package:aplikasi_supir/features/awal/layar_awal.dart';
import 'package:aplikasi_supir/features/beranda/layar_beranda.dart';
import 'package:aplikasi_supir/features/peta/peta_sesi.dart';
import 'package:aplikasi_supir/features/ringkasan/layar_ringkasan.dart';
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
        final s = AppState(layanan: f)..tileGagal = true;
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
          final baris = find.ancestor(
            of: find.text(p.judul),
            matching: find.byType(BarisCek),
          );
          final atur = find.descendant(of: baris, matching: find.text('Atur'));
          await tampilkan(t, atur);
          await t.tap(atur);
          await t.pumpAndSettle();
          await ketuk(t, 'Simulasikan sudah diatur');
        }
        await ketuk(t, 'Lanjut');
        await ketuk(t, 'Scan QR · simulasi DT-07');
        expect(find.byType(LayarBeranda), findsOneWidget);
        await ketuk(t, 'Ganti');
        await ketuk(t, 'DT-11');
        expect(s.truk!.nomor, 'DT-11');
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
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox.shrink());
      });
    }
  }
  testWidgets('rute langsung dilindungi dan akhir otomatis dari peta', (
    t,
  ) async {
    final f = FakeTrackingService(timerAktif: false)..uploadOffline = true;
    final s = AppState(layanan: f)..tileGagal = true;
    addTearDown(s.dispose);
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.pumpWidget(AplikasiSupir(state: s));
    await t.pumpAndSettle();
    Navigator.of(t.element(find.byType(LayarAwal))).pushNamed(NamaRute.peta);
    await t.pumpAndSettle();
    expect(find.text('Nomor HP'), findsOneWidget);
    siapkan(s);
    await s.mulaiSesi();
    await t.pumpAndSettle();
    Navigator.of(t.element(find.byType(Layar).last)).pushNamed(NamaRute.peta);
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
