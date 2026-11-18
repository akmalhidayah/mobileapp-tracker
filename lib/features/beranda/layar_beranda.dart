import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_ukuran.dart';
import '../../core/widgets/komponen.dart';

class LayarBeranda extends StatelessWidget {
  const LayarBeranda({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Layar(
      judul: 'Tracker Truk',
      logo: true,
      tampilkanIndikatorDemo: false,
      children: [
        Text('Halo, ${s.supir!.nama}', style: AppText.judul),
        const SizedBox(height: AppSpace.s8),
        Text('Siap untuk perjalanan hari ini?', style: AppText.isiBesar),
        const SizedBox(height: AppSpace.s24),
        KartuTruk(
          truk: s.truk!,
          namaVendor: s.supir!.vendor.namaSingkat,
          onGanti: () => buka(context, NamaRute.pilihTruk),
        ),
        ChipKesiapan(siap: s.semuaSiap, jumlah: s.jumlahSiap),
        if (!s.semuaSiap)
          Tombol(
            'Periksa kesiapan HP',
            sekunder: true,
            onTap: () => buka(context, NamaRute.kesiapan),
          ),
        const SizedBox(height: AppSpace.s32),
        Center(
          child: Container(
            width: AppUkuran.tombolMulai,
            height: AppUkuran.tombolMulai,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.aksenLembut,
                width: AppUkuran.cincinMulai,
              ),
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: AppColors.aksen,
                foregroundColor: AppColors.teks,
                disabledBackgroundColor: AppColors.nonaktif,
                disabledForegroundColor: AppColors.teksNonaktif,
              ),
              onPressed: s.bolehMulai
                  ? () async {
                      final ok = await s.mulaiSesi();
                      if (context.mounted) {
                        if (ok) {
                          buka(context, NamaRute.sesi, ganti: true);
                        } else {
                          pesan(
                            context,
                            'Sesi belum dapat dimulai. Periksa kesiapan HP.',
                          );
                        }
                      }
                    }
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_arrow_rounded,
                    size: AppUkuran.ikonBesar,
                  ),
                  Text(s.sibuk ? 'Memulai…' : 'Mulai', style: AppText.judul),
                  Text('sesi kerja', style: AppText.kecil),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.s24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: AppUkuran.ikonKecil,
              color: AppColors.teksSekunder,
            ),
            const SizedBox(width: AppSpace.s8),
            Flexible(
              child: Text(
                'Lokasi hanya direkam selama sesi aktif.',
                textAlign: TextAlign.center,
                style: AppText.kecil,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.s24),
        if (s.pendingLama > 0)
          BannerPeringatan(
            '${s.pendingLama} titik sesi sebelumnya belum terkirim. Antrean tetap tersimpan selama demo ini terbuka.',
          ),
        if (s.ringkasanTerakhir != null)
          Tombol(
            'Lihat ringkasan terakhir',
            sekunder: true,
            onTap: () => buka(context, NamaRute.ringkasan),
          ),
        TextButton.icon(
          onPressed: () {
            if (s.keluar()) buka(context, NamaRute.masuk, ganti: true);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.aksenTeks,
            minimumSize: const Size(0, AppUkuran.targetSentuh),
          ),
          icon: const Icon(Icons.logout_rounded, size: AppUkuran.ikonKecil),
          label: const Text('Keluar'),
        ),
      ],
    );
  }
}
