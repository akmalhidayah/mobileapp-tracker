import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_scope.dart';
import 'app/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_space.dart';
import 'core/widgets/bingkai_hp.dart';
import 'core/widgets/komponen.dart';
import 'data/services/akun_sopir_api.dart';
import 'data/services/fake_tracking_service.dart';
import 'state/app_state.dart';

void main() => runApp(const AplikasiSupir());

AkunSopirApi? _apiAkun() {
  if (_demo) return null;
  const alamat = String.fromEnvironment('AUTH_API_URL');
  final uri = AkunSopirApi.alamatServer(alamat);
  if (uri == null) return null;
  final perangkatMobile =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  return AkunSopirApi(
    alamat: uri,
    penyimpanan: perangkatMobile
        ? const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          )
        : null,
  );
}

const _demo = kDebugMode && bool.fromEnvironment('AUTH_DEMO');

class AplikasiSupir extends StatefulWidget {
  const AplikasiSupir({super.key, this.state});
  final AppState? state;
  @override
  State<AplikasiSupir> createState() => _AplikasiSupirState();
}

class _AplikasiSupirState extends State<AplikasiSupir> {
  late final AppState state =
      widget.state ??
      AppState(
        layanan: FakeTrackingService(),
        apiAkun: _apiAkun(),
        preferensi: _demo ? null : SharedPreferencesAsync(),
        loginDemo: _demo,
      );
  late Future<bool>? _pemulihan;

  @override
  void initState() {
    super.initState();
    _pemulihan = state.perluPulihkanLogin ? state.pulihkanLogin() : null;
  }

  @override
  void dispose() {
    if (widget.state == null) state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: FutureBuilder<bool>(
      future: _pemulihan,
      builder: (context, hasil) {
        final siap = _pemulihan == null || hasil.data == true;
        return MaterialApp(
          key: ValueKey(siap),
          title: 'Tracker Truk – Supir',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.terang,
          builder: (context, child) => BingkaiHp(child: child!),
          home: siap
              ? null
              : Scaffold(
                  body: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpace.s24),
                        child: hasil.connectionState == ConnectionState.done
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.pesanAkun ??
                                        'Login belum bisa dipulihkan.',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpace.s16),
                                  Tombol(
                                    'Coba lagi',
                                    onTap: () {
                                      setState(
                                        () =>
                                            _pemulihan = state.pulihkanLogin(),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : const CircularProgressIndicator(
                                semanticsLabel: 'Memeriksa sesi login',
                              ),
                      ),
                    ),
                  ),
                ),
          initialRoute: NamaRute.awal,
          onGenerateRoute: buatRute,
        );
      },
    ),
  );
}
