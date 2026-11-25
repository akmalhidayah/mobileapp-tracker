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

  Future<void> _konfirmasiKeluar(BuildContext context) async {
    final state = AppScope.baca(context);
    final ya = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Yakin ingin keluar?'),
        content: const Text(
          'Anda perlu memasukkan nomor HP dan PIN untuk masuk kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Ya, keluar'),
          ),
        ],
      ),
    );
    if (ya != true || !context.mounted) return;
    final berhasil = await state.keluar();
    if (berhasil && context.mounted) {
      buka(context, NamaRute.masuk, ganti: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final adaRingkasan = s.ringkasanTerakhir != null;
    return Layar(
      logo: true,
      tampilkanIndikatorDemo: false,
      aksiKiri: TextButton.icon(
        onPressed: s.akunSibuk ? null : () => _konfirmasiKeluar(context),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.aksenTeks,
          minimumSize: const Size(0, AppUkuran.targetSentuh),
        ),
        icon: const Icon(Icons.logout_rounded, size: AppUkuran.ikonKecil),
        label: const Text('Keluar'),
      ),
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
        Row(
          mainAxisAlignment: adaRingkasan
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 5,
              child: ChipKesiapan(siap: s.semuaSiap, jumlah: s.jumlahSiap),
            ),
            if (adaRingkasan) ...[
              const SizedBox(width: AppSpace.s8),
              Flexible(
                flex: 6,
                child: TextButton(
                  onPressed: () => buka(context, NamaRute.riwayat),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.aksenTeks,
                    minimumSize: const Size(0, AppUkuran.targetSentuh),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s8,
                    ),
                    textStyle: AppText.kecilTebal,
                  ),
                  child: const Text('Riwayat sesi', textAlign: TextAlign.end),
                ),
              ),
            ],
          ],
        ),
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
                        } else if (!s.sudahMasuk ||
                            !s.sudahSetuju ||
                            s.truk == null) {
                          buka(context, s.ruteSemestinya, ganti: true);
                        } else {
                          pesan(
                            context,
                            s.pesanAkun ?? 'Sesi belum dapat dimulai. Periksa kesiapan HP.',
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
        if (s.pesanAkun case final pesan?) BannerPeringatan(pesan),
      ],
    );
  }
}
