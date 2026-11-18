import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_space.dart';
import '../theme/app_text.dart';
import '../theme/app_ukuran.dart';

/// Sepasang logo asli dengan ukuran yang sama di semua header.
class LogoPerusahaan extends StatelessWidget {
  const LogoPerusahaan({super.key, this.ringkas = false, this.onTap});
  final bool ringkas;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s8,
        vertical: AppSpace.s4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in [
            ('logo_sig.png', 'SIG'),
            ('logo_semen_tonasa.png', 'Semen Tonasa'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
              child: Image.asset(
                'assets/images/${item.$1}',
                height: ringkas ? AppUkuran.logoHeader : AppUkuran.logoLogin,
                width: ringkas
                    ? AppUkuran.logoHeaderLebar
                    : AppUkuran.logoLoginLebar,
                fit: BoxFit.contain,
                semanticLabel: item.$2,
                errorBuilder: (_, _, _) => Text(item.$2, style: AppText.mikro),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Ikon garis dalam bidang lembut: konsisten untuk izin, privasi, dan statistik.
class IkonBidang extends StatelessWidget {
  const IkonBidang(
    this.ikon, {
    super.key,
    this.warna = AppColors.aksenTeks,
    this.latar = AppColors.aksenLembut,
    this.ringkas = false,
  });
  final IconData ikon;
  final Color warna, latar;
  final bool ringkas;
  @override
  Widget build(BuildContext context) => Container(
    width: ringkas ? AppUkuran.ikonBidangKecil : AppUkuran.targetSentuh,
    height: ringkas ? AppUkuran.ikonBidangKecil : AppUkuran.targetSentuh,
    decoration: BoxDecoration(color: latar, borderRadius: AppRadius.brInput),
    child: Icon(
      ikon,
      size: ringkas ? AppUkuran.ikonKecil : AppUkuran.ikon,
      color: warna,
    ),
  );
}

class IlustrasiTruk extends StatelessWidget {
  const IlustrasiTruk({
    super.key,
    this.tinggi = AppUkuran.ilustrasiTruk,
    this.lebar,
  });
  final double tinggi;
  final double? lebar;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/truk_tambang.png',
    height: tinggi,
    width: lebar,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
    // Seluruh armada memakai ilustrasi contoh yang sama, bukan foto unit asli.
    errorBuilder: (_, _, _) => SizedBox(
      height: tinggi,
      width: lebar,
      child: const Icon(
        Icons.local_shipping_outlined,
        size: AppUkuran.ikonRaksasa,
        color: AppColors.aksenTeks,
      ),
    ),
  );
}
