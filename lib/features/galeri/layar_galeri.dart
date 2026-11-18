import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/komponen.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/status_perjalanan.dart';
import '../peta/peta_sesi.dart';
import '../sesi_aktif/layar_sesi.dart';

class LayarGaleri extends StatelessWidget {
  const LayarGaleri({super.key});
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Layar(
      judul: 'Galeri komponen',
      kembali: true,
      children: [
        const LogoMerek(),
        Tombol('Tombol utama', onTap: () {}),
        Tombol('Tombol sekunder', sekunder: true, onTap: () {}),
        const Tombol('Nonaktif'),
        KartuTruk(truk: DummyData.daftarTruk[1], onGanti: () {}),
        const ChipKesiapan(siap: true, jumlah: 5),
        const ChipKesiapan(siap: false, jumlah: 2),
        const BannerPeringatan('Periksa kesiapan sebelum mulai.'),
        const BannerPeringatan('GPS mati.', bahaya: true),
        for (final s in StatusPerjalanan.values)
          PanelStatusPerjalanan(
            status: s,
            sedangKirim: false,
            onSinkronkan: () {},
          ),
        const KartuStatistik(
          label: 'Ritase',
          nilai: '12',
          ikon: Icons.local_shipping_outlined,
        ),
        const BarisRingkasan('Durasi', '01:23:45'),
        const LegendaPeta(),
      ],
    );
  }
}
