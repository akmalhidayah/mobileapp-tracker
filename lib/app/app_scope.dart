import 'package:flutter/widgets.dart';

import '../state/app_state.dart';

/// Menyediakan [AppState] ke seluruh pohon widget. Widget yang memanggil
/// [AppScope.of] dibangun ulang setiap state berubah.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  /// Mengambil state dan mendaftar untuk dibangun ulang saat berubah.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di atas widget ini');
    return scope!.notifier!;
  }

  /// Mengambil state tanpa mendaftar; untuk dipakai di dalam callback.
  static AppState baca(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di atas widget ini');
    return scope!.notifier!;
  }
}
