import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/komponen.dart';

class LayarDebug extends StatelessWidget {
  const LayarDebug({super.key});
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final s = AppScope.of(context);
    return Layar(
      judul: 'Debug simulasi',
      kembali: true,
      children: [
        const BannerPeringatan(
          'Kontrol khusus pengujian. Data hanya disimpan dalam memori.',
        ),
        for (final item in <(String, bool, ValueChanged<bool>)>[
          ('GPS mati', s.simulasiGpsMati, (v) => s.simulasiGpsMati = v),
          ('Izin lokasi dicabut', s.izinDicabut, (v) => s.izinDicabut = v),
          ('Tile peta gagal', s.tileGagal, (v) => s.tileGagal = v),
          ('Upload offline', s.uploadOffline, (v) => s.uploadOffline = v),
          (
            'Upload gagal (server simulasi)',
            s.gagalUpload,
            (v) => s.gagalUpload = v,
          ),
          (
            'Baterai rendah · 10%',
            s.baterai < 15,
            (v) => s.baterai = v ? 10 : 72,
          ),
          ('Sedang dicas', s.charging, (v) => s.charging = v),
          (
            'Percepatan waktu 5×',
            s.percepatan == 5,
            (v) => s.percepatan = v ? 5 : 1,
          ),
        ])
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.$1, style: AppText.isi),
            value: item.$2,
            onChanged: item.$3,
          ),
        if (s.sesi != null)
          Text(
            'Rekaman ${s.sesi!.totalRekaman} = ACK ${s.sesi!.titikTerkirim} + pending ${s.sesi!.belumTerkirim}\nSeq terakhir: ${s.sesi!.posisi?.seq ?? '—'}\nKualitas siklus: ${s.sesi!.perluDicek ? 'perlu dicek / ada jeda' : 'normal'}',
            style: AppText.kecil,
          ),
        Tombol(
          'Lompat ke 12 jam',
          sekunder: true,
          onTap: s.sesiAktif
              ? () => s.lompatKe(const Duration(hours: 12))
              : null,
        ),
        Tombol(
          'Lompat ke 16 jam',
          sekunder: true,
          onTap: s.sesiAktif
              ? () {
                  s.lompatKe(const Duration(hours: 16));
                  buka(context, NamaRute.ringkasan, ganti: true);
                }
              : null,
        ),
        Tombol(
          'Galeri komponen',
          sekunder: true,
          onTap: () => buka(context, NamaRute.galeri),
        ),
        Tombol(
          'Reset demo',
          bahaya: true,
          onTap: () async {
            await s.resetSemua();
            if (context.mounted) buka(context, NamaRute.masuk, ganti: true);
          },
        ),
      ],
    );
  }
}
