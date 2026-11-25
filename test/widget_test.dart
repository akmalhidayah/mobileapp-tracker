import 'dart:convert';

import 'package:aplikasi_supir/data/services/akun_sopir_api.dart';
import 'package:aplikasi_supir/data/services/fake_tracking_service.dart';
import 'package:aplikasi_supir/main.dart';
import 'package:aplikasi_supir/state/app_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('aplikasi menampilkan pintu masuk sopir', (tester) async {
    final state = AppState(layanan: FakeTrackingService(timerAktif: false));
    addTearDown(state.dispose);
    await tester.pumpWidget(AplikasiSupir(state: state));
    expect(find.text('Mulai'), findsOneWidget);
  });

  testWidgets('startup memulihkan akun ke beranda tanpa menampilkan form', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({
      'tracker_tonasa_login:https://tracker.example': 'token-uji',
    });
    final state = AppState(
      layanan: FakeTrackingService(timerAktif: false),
      apiAkun: AkunSopirApi(
        alamat: Uri.parse('https://tracker.example'),
        penyimpanan: const FlutterSecureStorage(),
        klien: MockClient((request) async {
          expect(request.url.path, '/api/v1/driver/session/');
          expect(request.headers['Authorization'], 'Bearer token-uji');
          return http.Response(
            jsonEncode({
              'pengemudi': {'nama': 'Sopir Uji', 'nomor_hp': '+6281234567890'},
              'ekspeditur': {
                'id': 5,
                'nama': 'Ekspeditur Uji',
                'nama_singkat': 'Uji',
              },
              'versi_persetujuan': versiPersetujuanSopir,
              'sudah_setuju': true,
              'truk_terpilih_id': 51,
              'truk': [
                {'id': 51, 'nomor_lambung': 'UJI-51', 'kapasitas_ton': '28.50'},
              ],
            }),
            200,
          );
        }),
      ),
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(AplikasiSupir(state: state));
    await tester.pumpAndSettle();
    expect(find.text('Halo, Sopir Uji'), findsOneWidget);
    expect(find.text('UJI-51'), findsOneWidget);
    expect(find.text('Persetujuan'), findsNothing);
  });
}
