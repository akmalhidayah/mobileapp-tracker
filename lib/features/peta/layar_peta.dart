import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/geo.dart';
import '../../core/widgets/komponen.dart';
import '../../core/widgets/visual_identitas.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/status_perjalanan.dart';
import 'kontrol_peta.dart';
import 'peta_sesi.dart';

class LayarPeta extends StatelessWidget {
  const LayarPeta({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context), s = state.sesi!;
    final bongkar =
        s.status == StatusPerjalanan.bermuatan ||
        s.status == StatusPerjalanan.diDumping;
    final tujuan = bongkar ? DummyData.titikBongkar : DummyData.titikMuat;
    final status = s.lokasiTersedia ? s.status.tahap : 'Lokasi usang';
    final warna = s.lokasiTersedia
        ? warnaStatusPeta(s.status)
        : AppColors.teksSekunder;
    final posisi = s.posisi;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              buka(context, state.ruteSemestinya, ganti: true);
            }
          },
        ),
        title: const Text('Peta perjalanan'),
        actions: const [LogoPerusahaan(ringkas: true)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PetaSesi(
                snapshot: s,
                tileGagal: state.tileGagal,
                penuh: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s16,
                AppSpace.s12,
                AppSpace.s16,
                AppSpace.s8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(s.nomorTruk, style: AppText.nomorTruk),
                      ),
                      Flexible(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: warna.withValues(alpha: .10),
                            borderRadius: AppRadius.brChip,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.s8,
                              vertical: AppSpace.s4,
                            ),
                            child: Text(
                              status,
                              style: AppText.kecilTebal.copyWith(color: warna),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s4),
                  Text('Tujuan · ${tujuan.nama}', style: AppText.kecil),
                  const Divider(color: AppColors.garis, height: AppSpace.s16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _NilaiPeta(
                          'Kecepatan simulasi',
                          posisi == null || !s.lokasiTersedia
                              ? '—'
                              : formatKecepatan(posisi.kecepatan),
                        ),
                      ),
                      const SizedBox(width: AppSpace.s8),
                      Expanded(
                        child: _NilaiPeta(
                          'Jarak lurus (simulasi)',
                          posisi == null
                              ? '—'
                              : formatJarak(
                                  jarakMeter(posisi.posisi, tujuan.posisi),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NilaiPeta extends StatelessWidget {
  const _NilaiPeta(this.label, this.nilai);

  final String label, nilai;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppText.mikro),
      const SizedBox(height: AppSpace.s4),
      Text(nilai, style: AppText.kecilTebal),
    ],
  );
}
