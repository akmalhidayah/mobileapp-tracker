import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/komponen.dart';
import '../../data/models/ringkasan_sesi.dart';

class LayarRiwayatSesi extends StatelessWidget {
  const LayarRiwayatSesi({super.key});

  @override
  Widget build(BuildContext context) {
    final riwayat = AppScope.of(context).riwayat
      ..sort((a, b) => b.mulai.compareTo(a.mulai));
    final perTanggal = <String, List<RingkasanSesi>>{};
    for (final sesi in riwayat) {
      final tanggal = formatTanggal(waktuWita(sesi.mulai));
      perTanggal.putIfAbsent(tanggal, () => []).add(sesi);
    }

    return Layar(
      judul: 'Riwayat sesi',
      kembali: true,
      children: [
        if (perTanggal.isEmpty)
          KartuInfo(child: Text('Belum ada sesi selesai.', style: AppText.isi)),
        for (final entri in perTanggal.entries)
          KartuInfo(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              key: PageStorageKey(entri.key),
              initiallyExpanded: entri.key == perTanggal.keys.first,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(entri.key, style: AppText.label),
              subtitle: Text(
                '${entri.value.length} sesi · '
                '${entri.value.fold(0, (total, sesi) => total + sesi.ritase)} ritase',
                style: AppText.kecil,
              ),
              childrenPadding: const EdgeInsets.only(bottom: AppSpace.s4),
              children: [
                const Divider(height: 1, color: AppColors.garis),
                for (final sesi in entri.value)
                  ListTile(
                    title: Text(sesi.truk.nomor, style: AppText.kecilTebal),
                    subtitle: Text(
                      '${_rentangWaktu(sesi, entri.key)} · ${sesi.ritase} ret',
                      style: AppText.kecil,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => buka(
                      context,
                      NamaRute.ringkasan,
                      argumen: sesi.sessionId,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static String _rentangWaktu(RingkasanSesi sesi, String tanggalMulai) {
    final mulai = waktuWita(sesi.mulai);
    final selesai = waktuWita(sesi.selesai);
    final tanggalSelesai = formatTanggal(selesai);
    final jamSelesai = formatJam(selesai);
    final akhir = tanggalMulai == tanggalSelesai
        ? jamSelesai
        : '$tanggalSelesai, $jamSelesai';
    return '${formatJam(mulai)}–$akhir WITA';
  }
}
