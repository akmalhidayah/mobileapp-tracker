import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_space.dart';
import 'app_text.dart';
import 'app_ukuran.dart';

/// Tema Material yang dibangun dari token desain.
abstract final class AppTheme {
  static ThemeData get terang {
    const skema = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.aksen,
      onPrimary: AppColors.teks,
      secondary: AppColors.gelap,
      onSecondary: AppColors.teksTerbalik,
      error: AppColors.bahaya,
      onError: AppColors.teksTerbalik,
      surface: AppColors.permukaan,
      onSurface: AppColors.teks,
      onSurfaceVariant: AppColors.teksSekunder,
      outline: AppColors.garisKuat,
      outlineVariant: AppColors.garis,
      surfaceTint: AppColors.transparan,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      scaffoldBackgroundColor: AppColors.latar,
      canvasColor: AppColors.latar,
      dividerColor: AppColors.garis,
      splashFactory: InkRipple.splashFactory,
      textTheme: TextTheme(
        displaySmall: AppText.angkaBesar,
        headlineLarge: AppText.judulBesar,
        headlineMedium: AppText.judul,
        headlineSmall: AppText.subjudulBesar,
        titleLarge: AppText.subjudul,
        titleMedium: AppText.label,
        bodyLarge: AppText.isiBesar,
        bodyMedium: AppText.isi,
        bodySmall: AppText.kecil,
        labelLarge: AppText.tombol,
        labelMedium: AppText.kecilTebal,
        labelSmall: AppText.mikro,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.teks,
        size: AppUkuran.ikon,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.latar,
        foregroundColor: AppColors.teks,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.nomorTruk,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.garis,
        thickness: AppUkuran.garis,
        space: AppUkuran.garis,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.permukaan,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.brKartuBesar,
        ),
        titleTextStyle: AppText.subjudul,
        contentTextStyle: AppText.isi,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.permukaan,
        modalBackgroundColor: AppColors.permukaan,
        modalBarrierColor: AppColors.tirai,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLembarBawah),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.gelap,
        elevation: 0,
        contentTextStyle: AppText.isi.copyWith(color: AppColors.teksTerbalik),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.brTombolKecil,
        ),
        insetPadding: const EdgeInsets.all(AppSpace.s16),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: AppColors.gelap,
          borderRadius: AppRadius.brKecil,
        ),
        textStyle: AppText.mikro.copyWith(color: AppColors.teksTerbalik),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (keadaan) => keadaan.contains(WidgetState.selected)
              ? AppColors.teks
              : AppColors.teksSekunder,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (keadaan) => keadaan.contains(WidgetState.selected)
              ? AppColors.aksen
              : AppColors.nonaktif,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.garisKuat),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.teks,
        selectionColor: AppColors.aksenLembut,
        selectionHandleColor: AppColors.aksenTeks,
      ),
    );
  }
}
