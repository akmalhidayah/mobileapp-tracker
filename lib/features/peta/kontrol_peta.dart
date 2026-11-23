import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_ukuran.dart';
import '../../data/models/status_perjalanan.dart';

Color warnaStatusPeta(StatusPerjalanan status) => switch (status) {
  StatusPerjalanan.kosong => AppColors.info,
  StatusPerjalanan.diLoading => AppColors.sukses,
  StatusPerjalanan.bermuatan => AppColors.aksenTeks,
  StatusPerjalanan.diDumping => AppColors.titikBongkar,
};

class TombolPeta extends StatelessWidget {
  const TombolPeta({
    super.key,
    required this.label,
    required this.ikon,
    required this.onTap,
    this.aktif = false,
    this.hanyaIkon = false,
  });

  final String label;
  final IconData ikon;
  final VoidCallback? onTap;
  final bool aktif, hanyaIkon;

  @override
  Widget build(BuildContext context) {
    final gaya = OutlinedButton.styleFrom(
      elevation: 1,
      shadowColor: AppColors.tirai,
      backgroundColor: aktif ? AppColors.aksenLembut : AppColors.permukaan,
      foregroundColor: aktif ? AppColors.aksenTeks : AppColors.teks,
      side: const BorderSide(color: AppColors.garis),
      padding: EdgeInsets.symmetric(horizontal: hanyaIkon ? 0 : AppSpace.s8),
      minimumSize: const Size(AppUkuran.targetSentuh, 34),
      tapTargetSize: MaterialTapTargetSize.padded,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.brTombolKecil,
      ),
      textStyle: AppText.kecilTebal,
    );
    final gambar = Icon(ikon, size: AppUkuran.ikonKecil);
    return hanyaIkon
        ? Tooltip(
            message: label,
            child: OutlinedButton(onPressed: onTap, style: gaya, child: gambar),
          )
        : OutlinedButton.icon(
            onPressed: onTap,
            style: gaya,
            icon: gambar,
            label: Text(label),
          );
  }
}

class KreditPeta extends StatelessWidget {
  const KreditPeta({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.kreditPeta,
      borderRadius: AppRadius.brKecil,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s8,
        vertical: AppSpace.s4,
      ),
      child: Text('© OpenStreetMap contributors', style: AppText.mikro),
    ),
  );
}

class LegendaPeta extends StatelessWidget {
  const LegendaPeta({
    super.key,
    this.warnaTruk = AppColors.aksenTeks,
    this.tinggiMaks = 200,
  });

  final Color warnaTruk;
  final double tinggiMaks;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.permukaan,
    elevation: 3,
    borderRadius: AppRadius.brInput,
    clipBehavior: Clip.antiAlias,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 290, maxHeight: tinggiMaks),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _GrupLegenda('Simbol peta', [
                ('Truk saya', warnaTruk, Icons.local_shipping_outlined),
                ('Area muat', AppColors.sukses, Icons.location_on_rounded),
                (
                  'Area bongkar',
                  AppColors.titikBongkar,
                  Icons.location_on_rounded,
                ),
                ('Rute simulasi', AppColors.ruteGaris, Icons.horizontal_rule),
                ('Jejak sesi', AppColors.jejak, Icons.horizontal_rule),
              ]),
            ),
            const SizedBox(width: AppSpace.s12),
            Expanded(
              child: _GrupLegenda('Status truk', [
                for (final status in StatusPerjalanan.values)
                  (status.tahap, warnaStatusPeta(status), null),
                ('Lokasi usang', AppColors.teksSekunder, null),
              ]),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GrupLegenda extends StatelessWidget {
  const _GrupLegenda(this.judul, this.daftar);

  final String judul;
  final List<(String, Color, IconData?)> daftar;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(judul, style: AppText.kecilTebal),
      for (final (label, warna, ikon) in daftar)
        Padding(
          padding: const EdgeInsets.only(top: AppSpace.s4),
          child: Row(
            children: [
              SizedBox(
                width: AppUkuran.simbolLegenda,
                child: Icon(
                  ikon ?? Icons.circle,
                  size: ikon != null ? AppUkuran.simbolLegenda : 8,
                  color: warna,
                ),
              ),
              const SizedBox(width: AppSpace.s4),
              Expanded(child: Text(label, style: AppText.mikro)),
            ],
          ),
        ),
    ],
  );
}
