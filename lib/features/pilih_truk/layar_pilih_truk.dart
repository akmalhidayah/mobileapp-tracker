import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/komponen.dart';
import '../../core/widgets/visual_identitas.dart';
import '../../data/models/truk.dart';

class LayarPilihTruk extends StatefulWidget {
  const LayarPilihTruk({super.key});
  @override
  State<LayarPilihTruk> createState() => _LayarPilihTrukState();
}

class _LayarPilihTrukState extends State<LayarPilihTruk> {
  /// Pencarian baru berguna kalau armada vendor cukup banyak.
  static const int _batasPencarian = 6;
  String _kata = '';

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final vendor = s.supir?.vendor;
    if (vendor == null) return const SizedBox.shrink();
    final semua = s.daftarTruk;
    final contohScan = semua.isEmpty
        ? null
        : semua.length > 1
        ? semua[1]
        : semua.first;
    final tampil = [
      for (final t in semua)
        if (t.nomor.toLowerCase().contains(_kata.trim().toLowerCase())) t,
    ];

    Future<void> pilih(Truk truk) async {
      final berhasil = await s.pilihTruk(truk);
      if (context.mounted && (berhasil || !s.sudahMasuk)) {
        buka(context, s.ruteSemestinya, ganti: true);
      }
    }

    return Layar(
      judul: 'Pilih truk',
      judulVendorUtama: true,
      kembali: s.truk != null,
      children: [
        Text('Truk yang Anda bawa', style: AppText.judul),
        const SizedBox(height: AppSpace.s16),
        KartuInfo(
          warna: AppColors.aksenLembut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ARMADA ${vendor.namaSingkat.toUpperCase()}',
                style: AppText.penanda.copyWith(color: AppColors.aksenTeks),
              ),
              const SizedBox(height: AppSpace.s8),
              const SizedBox(width: double.infinity, child: IlustrasiTruk()),
              const SizedBox(height: AppSpace.s8),
              Text('Truk angkut clinker', style: AppText.nomorTruk),
              const SizedBox(height: AppSpace.s4),
              Text(
                'Ilustrasi kendaraan · pilih nomor unit di bawah.',
                style: AppText.kecil,
              ),
            ],
          ),
        ),
        if (s.loginDemo)
          Tombol(
            contohScan == null
                ? 'Scan QR · belum ada unit'
                : 'Scan QR · simulasi ${contohScan.nomor}',
            ikon: Icons.qr_code_scanner,
            onTap: contohScan == null ? null : () => pilih(contohScan),
          ),
        if (!s.loginDemo)
          Tombol(
            'Muat ulang penugasan',
            sekunder: true,
            ikon: Icons.refresh,
            onTap: s.akunSibuk
                ? null
                : () async {
                    await s.muatPenugasan();
                    if (context.mounted && !s.sudahMasuk) {
                      buka(context, NamaRute.masuk, ganti: true);
                    }
                  },
          ),
        if (s.pesanAkun case final pesan?) BannerPeringatan(pesan),
        const SizedBox(height: AppSpace.s24),
        Text('NOMOR LAMBUNG · ${semua.length} UNIT', style: AppText.penanda),
        const SizedBox(height: AppSpace.s12),
        if (semua.length > _batasPencarian) ...[
          TextField(
            onChanged: (v) => setState(() => _kata = v),
            textInputAction: TextInputAction.search,
            style: AppText.isi,
            decoration: InputDecoration(
              hintText: 'Cari nomor lambung, mis. DT-3',
              hintStyle: AppText.kecil,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.teksSekunder,
              ),
              filled: true,
              fillColor: AppColors.permukaan,
              contentPadding: const EdgeInsets.all(AppSpace.s16),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.brInput,
                borderSide: BorderSide(color: AppColors.garis),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.brInput,
                borderSide: BorderSide(color: AppColors.aksenTeks, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.s12),
        ],
        if (tampil.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.s16),
            child: Text(
              semua.isEmpty
                  ? 'Belum ada truk yang ditugaskan. Hubungi admin.'
                  : 'Tidak ada nomor lambung "$_kata" di armada ${vendor.namaSingkat}.',
              textAlign: TextAlign.center,
              style: AppText.kecil,
            ),
          ),
        for (final t in tampil)
          BarisTruk(
            truk: t,
            namaVendor: vendor.namaSingkat,
            onTap: s.akunSibuk ? null : () => pilih(t),
          ),
      ],
    );
  }
}
