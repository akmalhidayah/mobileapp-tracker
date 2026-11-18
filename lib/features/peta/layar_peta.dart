import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../core/utils/geo.dart';
import '../../core/widgets/komponen.dart';
import '../../data/models/status_perjalanan.dart';
import 'peta_sesi.dart';

class LayarPeta extends StatelessWidget {
  const LayarPeta({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context), s = state.sesi!;
    final bongkar =
        s.status == StatusPerjalanan.bermuatan ||
        s.status == StatusPerjalanan.diDumping;
    final tujuan = bongkar ? state.areaBongkar : state.areaMuat;
    return Layar(
      judul: 'Peta perjalanan',
      kembali: true,
      children: [
        Text('${s.nomorTruk} · ${s.status.nama}', style: AppText.subjudul),
        const SizedBox(height: AppSpace.s8),
        Text(
          'Koordinat contoh · ${tujuan.nama} sebagai tujuan',
          style: AppText.kecil,
        ),
        const SizedBox(height: AppSpace.s12),
        SizedBox(
          height: 420,
          child: PetaSesi(snapshot: s, tileGagal: state.tileGagal, penuh: true),
        ),
        const SizedBox(height: AppSpace.s16),
        const LegendaPeta(),
        const SizedBox(height: AppSpace.s16),
        if (!s.lokasiTersedia)
          const BannerPeringatan(
            'Lokasi tidak tersedia. Posisi terakhir ditampilkan sebagai data usang.',
            bahaya: true,
          ),
        BarisRingkasan(
          'Kecepatan simulasi',
          s.posisi == null || !s.lokasiTersedia
              ? '—'
              : formatKecepatan(s.posisi!.kecepatan),
        ),
        BarisRingkasan(
          'Perkiraan garis lurus',
          s.posisi == null
              ? '—'
              : formatJarak(
                  jarakMeter(s.posisi!.posisi, pusatPoligon(tujuan.poligon)),
                ),
        ),
        Text(
          'Kecepatan dan perjalanan dipercepat untuk demo; bukan pengukuran fisik aktual.',
          style: AppText.kecil,
        ),
      ],
    );
  }
}
