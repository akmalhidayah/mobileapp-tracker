import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_ukuran.dart';

/// Di web, membatasi aplikasi ke lebar HP dan menaruhnya di tengah layar.
/// Di Android anak ditampilkan apa adanya.
class BingkaiHp extends StatelessWidget {
  const BingkaiHp({super.key, required this.child, this.aktif = kIsWeb});

  final Widget child;

  /// Bisa dipaksa lewat parameter untuk keperluan uji.
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    if (!aktif) return child;

    final media = MediaQuery.of(context);
    final lebar = media.size.width > AppUkuran.lebarMaksWeb
        ? AppUkuran.lebarMaksWeb
        : media.size.width;

    return ColoredBox(
      color: AppColors.latarLuar,
      child: Center(
        child: SizedBox(
          width: lebar,
          child: ClipRect(
            // Ukuran layar di MediaQuery disesuaikan supaya dialog, bottom
            // sheet, dan snackbar ikut memakai lebar HP.
            child: MediaQuery(
              data: media.copyWith(size: Size(lebar, media.size.height)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
