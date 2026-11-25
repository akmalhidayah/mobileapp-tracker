import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_ukuran.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/komponen.dart';

class LayarRingkasan extends StatelessWidget {
  const LayarRingkasan({super.key, this.idSesi});
  final String? idSesi;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final dariRiwayat = idSesi != null;
    final r = dariRiwayat
        ? state.riwayat.where((sesi) => sesi.sessionId == idSesi).firstOrNull
        : state.ringkasanTerakhir;
    if (r == null) {
      return Layar(
        judul: 'Ringkasan sesi',
        kembali: true,
        children: [Text('Ringkasan sesi tidak tersedia.', style: AppText.isi)],
      );
    }
    final kapasitas = r.truk.kapasitasTon;
    String tampil(num nilai) =>
        formatAngka(nilai, desimal: nilai == nilai.round() ? 0 : 2);
    return Layar(
      judul: 'Ringkasan sesi',
      kembali: dariRiwayat,
      aksi: kDebugMode ? tombolDebug(context) : null,
      children: [
        if (!dariRiwayat) ...[
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.sukses,
            size: AppUkuran.ikonRaksasa,
          ),
          const SizedBox(height: AppSpace.s16),
          Text(
            'Sesi selesai',
            style: AppText.judul,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.s8),
          Text(
            'Perekaman lokasi sudah berhenti.',
            style: AppText.isi,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.s24),
        ],
        if (r.otomatis)
          const BannerPeringatan(
            'Sesi dihentikan otomatis karena mencapai batas 16 jam.',
          ),
        KartuInfo(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LAPORAN PERJALANAN', style: AppText.penanda),
              const SizedBox(height: AppSpace.s8),
              BarisRingkasan('Ekspeditur', state.supir!.vendor.nama),
              BarisRingkasan('Nomor lambung', r.truk.nomor),
              BarisRingkasan('Mulai', formatTanggalJam(r.mulai)),
              BarisRingkasan('Selesai', formatTanggalJam(r.selesai)),
              BarisRingkasan('Durasi', formatDurasi(r.durasi)),
              BarisRingkasan('Jumlah ritase', '${r.ritase} ret'),
              BarisRingkasan(
                'Kapasitas truk',
                kapasitas == null ? '—' : '${tampil(kapasitas)} ton/ret',
              ),
              BarisRingkasan(
                'Estimasi muatan',
                kapasitas == null ? '—' : '${tampil(r.ritase * kapasitas)} ton',
              ),
            ],
          ),
        ),
        Text(
          'Estimasi muatan dihitung dari ritase × kapasitas truk. '
          'Berat muatan aktual dan rekap harian per ekspeditur disiapkan '
          'untuk laporan admin.',
          style: AppText.kecil,
        ),
        if (!dariRiwayat) ...[
          const SizedBox(height: AppSpace.s16),
          Tombol(
            'Kembali ke Beranda',
            onTap: () => buka(context, NamaRute.beranda, ganti: true),
          ),
        ],
      ],
    );
  }
}
