import 'package:material_ui/material_ui.dart';

import 'app_scope.dart';
import 'nama_rute.dart';
import '../features/awal/layar_awal.dart';
import '../features/persetujuan/layar_persetujuan.dart';
import '../features/kesiapan/layar_kesiapan.dart';
import '../features/pilih_truk/layar_pilih_truk.dart';
import '../features/beranda/layar_beranda.dart';
import '../features/sesi_aktif/layar_sesi.dart';
import '../features/peta/layar_peta.dart';
import '../features/ringkasan/layar_ringkasan.dart';
import '../features/debug/layar_debug.dart';
import '../features/galeri/layar_galeri.dart';
export 'nama_rute.dart';

Route<dynamic> buatRute(RouteSettings pengaturan) => MaterialPageRoute<void>(
  settings: pengaturan,
  builder: (context) {
    final nama = AppScope.of(context)
        .lindungiRute(pengaturan.name ?? NamaRute.awal);
    return switch (nama) {
      NamaRute.awal => const LayarAwal(),
      NamaRute.persetujuan => const LayarPersetujuan(),
      NamaRute.kesiapan => const LayarKesiapan(),
      NamaRute.pilihTruk => const LayarPilihTruk(),
      NamaRute.beranda => const LayarBeranda(),
      NamaRute.sesi => const LayarSesi(),
      NamaRute.peta => const LayarPeta(),
      NamaRute.ringkasan => const LayarRingkasan(),
      NamaRute.debug => const LayarDebug(),
      NamaRute.galeri => const LayarGaleri(),
      _ => const LayarAwal(bukaLogin: true),
    };
  },
);
