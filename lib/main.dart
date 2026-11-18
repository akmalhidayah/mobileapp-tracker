import 'package:material_ui/material_ui.dart';

import 'app/app_scope.dart';
import 'app/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/bingkai_hp.dart';
import 'data/services/fake_tracking_service.dart';
import 'state/app_state.dart';

void main() => runApp(const AplikasiSupir());

class AplikasiSupir extends StatefulWidget {
  const AplikasiSupir({super.key, this.state});
  final AppState? state;
  @override
  State<AplikasiSupir> createState() => _AplikasiSupirState();
}

class _AplikasiSupirState extends State<AplikasiSupir> {
  late final AppState state =
      widget.state ?? AppState(layanan: FakeTrackingService());
  @override
  void dispose() {
    if (widget.state == null) state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: MaterialApp(
      title: 'Tracker Truk – Supir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.terang,
      builder: (context, child) => BingkaiHp(child: child!),
      initialRoute: NamaRute.awal,
      onGenerateRoute: buatRute,
    ),
  );
}
