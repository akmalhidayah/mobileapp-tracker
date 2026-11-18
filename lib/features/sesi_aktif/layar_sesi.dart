import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/komponen.dart';
import '../../core/widgets/visual_identitas.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_ukuran.dart';
import '../../core/utils/format.dart';
import '../../data/models/snapshot_sesi.dart';
import '../../data/models/status_perjalanan.dart';
import '../peta/peta_sesi.dart';

class LayarSesi extends StatelessWidget {
  const LayarSesi({super.key});
  Future<void> _selesai(BuildContext context) async {
    final state = AppScope.baca(context);
    final ya = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Selesaikan sesi?'),
        content: const Text(
          'Perekaman lokasi akan berhenti. Pengiriman data akan dicoba; data yang belum terkirim tetap menunggu di antrean demo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Ya, selesai'),
          ),
        ],
      ),
    );
    if (ya != true || !context.mounted) return;
    await state.selesaiSesi();
    if (context.mounted) buka(context, NamaRute.ringkasan, ganti: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context), s = state.sesi!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          pesan(context, 'Gunakan Selesai sesi untuk menghentikan perekaman.');
        }
      },
      child: Layar(
        judul: 'Sesi aktif',
        logo: true,
        aksi: kDebugMode ? tombolDebug(context) : null,
        children: [
          HeaderSesi(snapshot: s),
          const SizedBox(height: AppSpace.s16),
          if (!s.gpsAktif)
            const BannerPeringatan(
              'GPS mati. Perekaman lokasi dijeda; durasi sesi tetap berjalan.',
              bahaya: true,
            ),
          if (!s.izinLokasi)
            const BannerPeringatan(
              'Izin lokasi dicabut. Tidak ada titik baru; Anda tetap dapat menyelesaikan sesi.',
              bahaya: true,
            ),
          if (s.baterai < 15 && !s.sedangDicas)
            const BannerPeringatan(
              'Baterai hampir habis. Sambungkan pengisi daya.',
              bahaya: true,
            ),
          if (s.pengingat12Jam)
            const BannerPeringatan(
              'Sesi sudah mencapai 12 jam. Ingat untuk menyelesaikan sesi; sesi berhenti otomatis pada 16 jam.',
            ),
          if (s.gagalKirim)
            const BannerPeringatan(
              'Pengiriman simulasi gagal. Titik tetap tersimpan dalam antrean.',
              bahaya: true,
            ),
          if (!s.lokasiTersedia && s.posisi != null)
            Text(
              'Posisi terakhir usang · ${formatLalu(s.waktu.difference(s.posisi!.waktu))}',
              style: AppText.kecil,
            ),
          PetaMini(
            snapshot: s,
            tileGagal: state.tileGagal,
            onPerbesar: () => buka(context, NamaRute.peta),
          ),
          PanelStatusPerjalanan(
            status: s.status,
            sedangKirim: s.sedangKirim,
            onSinkronkan: () => state.kirimSekarang(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: KartuStatistik(
                  label: 'Ritase simulasi',
                  nilai: '${s.ritase}',
                  ikon: Icons.local_shipping_outlined,
                ),
              ),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: KartuStatistik(
                  label: 'Belum terkirim',
                  nilai: '${s.belumTerkirim}',
                  ikon: Icons.cloud_upload_outlined,
                  warna: AppColors.info,
                  latarIkon: AppColors.infoLembut,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: KartuStatistik(
                  label: 'GPS / izin',
                  nilai: s.lokasiTersedia ? 'Aktif' : 'Terhenti',
                  ikon: Icons.gps_fixed,
                  warna: s.lokasiTersedia ? AppColors.sukses : AppColors.bahaya,
                  latarIkon: s.lokasiTersedia
                      ? AppColors.suksesLembut
                      : AppColors.bahayaLembut,
                ),
              ),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: KartuStatistik(
                  label: s.sedangDicas ? 'Sedang dicas' : 'Baterai',
                  nilai: '${s.baterai}%',
                  ikon: Icons.battery_charging_full,
                  warna: s.baterai < 15 && !s.sedangDicas
                      ? AppColors.bahaya
                      : AppColors.sukses,
                  latarIkon: s.baterai < 15 && !s.sedangDicas
                      ? AppColors.bahayaLembut
                      : AppColors.suksesLembut,
                ),
              ),
            ],
          ),
          Text(
            s.sedangKirim
                ? 'Mengirim data simulasi…'
                : s.kirimTerakhir == null
                ? 'Belum ada pengiriman berhasil.'
                : 'Sinkronisasi terakhir ${formatLalu(s.waktu.difference(s.kirimTerakhir!))}.',
            style: AppText.kecil,
          ),
          if (state.pendingLama > 0)
            Text(
              '${state.pendingLama} titik sesi lama juga menunggu pengiriman.',
              style: AppText.kecil,
            ),
          Tombol(
            'Selesai sesi',
            bahaya: true,
            sibuk: state.sibuk,
            onTap: () => _selesai(context),
          ),
        ],
      ),
    );
  }
}

class HeaderSesi extends StatelessWidget {
  const HeaderSesi({super.key, required this.snapshot});
  final SnapshotSesi snapshot;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpace.s20),
    decoration: const BoxDecoration(
      borderRadius: AppRadius.brKartuBesar,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.gelap, AppColors.headerLembut],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                snapshot.nomorTruk,
                style: AppText.nomorTruk.copyWith(
                  color: AppColors.teksTerbalik,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s8,
                vertical: AppSpace.s4,
              ),
              decoration: BoxDecoration(
                color: AppColors.permukaan.withValues(alpha: 0.1),
                borderRadius: AppRadius.brChip,
              ),
              child: Text(
                'SESI AKTIF',
                style: AppText.mikro.copyWith(color: AppColors.teksTerbalik),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.s16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DURASI SESI',
                    style: AppText.penanda.copyWith(
                      color: AppColors.teksTerbalikSekunder,
                    ),
                  ),
                  const SizedBox(height: AppSpace.s8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatDurasi(snapshot.durasi),
                      style: AppText.angkaBesar.copyWith(
                        color: AppColors.teksTerbalik,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s8),
            const IlustrasiTruk(
              tinggi: AppUkuran.kotakPenanda,
              lebar: AppUkuran.thumbnailSesi,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.s12),
        Row(
          children: [
            Icon(
              snapshot.lokasiTersedia
                  ? Icons.my_location_rounded
                  : Icons.location_off_outlined,
              size: AppUkuran.ikonKecil,
              color: snapshot.lokasiTersedia
                  ? AppColors.suksesTerang
                  : AppColors.teksTerbalikSekunder,
            ),
            const SizedBox(width: AppSpace.s8),
            Expanded(
              child: Text(
                snapshot.lokasiTersedia
                    ? 'Merekam lokasi simulasi'
                    : 'Lokasi dijeda',
                style: AppText.kecil.copyWith(
                  color: snapshot.lokasiTersedia
                      ? AppColors.suksesTerang
                      : AppColors.teksTerbalikSekunder,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class PanelStatusPerjalanan extends StatelessWidget {
  const PanelStatusPerjalanan({
    super.key,
    required this.status,
    required this.sedangKirim,
    required this.onSinkronkan,
  });
  final StatusPerjalanan status;
  final bool sedangKirim;
  final VoidCallback onSinkronkan;
  static IconData _ikon(StatusPerjalanan tahap) => switch (tahap) {
    StatusPerjalanan.kosong => Icons.local_shipping_outlined,
    StatusPerjalanan.diLoading => Icons.construction_rounded,
    StatusPerjalanan.bermuatan => Icons.inventory_2_outlined,
    StatusPerjalanan.diDumping => Icons.file_download_outlined,
  };
  @override
  Widget build(BuildContext context) => KartuInfo(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('STATUS PERJALANAN', style: AppText.penanda)),
            IconButton(
              tooltip: sedangKirim
                  ? 'Sedang menyinkronkan data'
                  : 'Sinkronkan data sekarang',
              onPressed: sedangKirim ? null : onSinkronkan,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.aksenLembut,
                foregroundColor: AppColors.aksenTeks,
              ),
              icon: sedangKirim
                  ? const SizedBox(
                      width: AppUkuran.ikonKecil,
                      height: AppUkuran.ikonKecil,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.s8),
        Text(status.nama, style: AppText.subjudul),
        const SizedBox(height: AppSpace.s4),
        Text(status.keterangan, style: AppText.kecil),
        const SizedBox(height: AppSpace.s20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final tahap in StatusPerjalanan.values)
              Expanded(
                child: Semantics(
                  selected: tahap == status,
                  child: Column(
                    children: [
                      IkonBidang(
                        _ikon(tahap),
                        ringkas: true,
                        warna: tahap == status
                            ? AppColors.aksenTeks
                            : AppColors.teksSekunder,
                        latar: tahap == status
                            ? AppColors.aksenLembut
                            : AppColors.latar,
                      ),
                      const SizedBox(height: AppSpace.s8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.s4,
                        ),
                        child: Text(
                          tahap.tahap,
                          textAlign: TextAlign.center,
                          style: AppText.mikro.copyWith(
                            fontWeight: tahap == status
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: tahap == status
                                ? AppColors.aksenTeks
                                : AppColors.teksSekunder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
