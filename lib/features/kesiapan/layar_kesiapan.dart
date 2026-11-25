import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_ukuran.dart';
import '../../core/widgets/komponen.dart';
import '../../core/widgets/visual_identitas.dart';
import '../../data/models/pengaturan_hp.dart';

IconData _ikonPengaturan(PengaturanHp p) => switch (p) {
  PengaturanHp.izinLokasi => Icons.location_on_outlined,
  PengaturanHp.notifikasi => Icons.notifications_none_rounded,
  PengaturanHp.optimasiBaterai => Icons.battery_charging_full_rounded,
  PengaturanHp.mulaiOtomatis => Icons.autorenew_rounded,
  PengaturanHp.gps => Icons.gps_fixed_rounded,
};

class LayarKesiapan extends StatelessWidget {
  const LayarKesiapan({super.key});

  Future<void> _atur(BuildContext context, PengaturanHp p) async {
    final sudahSiap = AppScope.baca(context).siap(p);
    final hasil = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLogin),
      clipBehavior: Clip.antiAlias,
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
      sheetAnimationStyle: AnimationStyle(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
        reverseDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
      ),
      builder: (lembar) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s24,
            AppSpace.s8,
            AppSpace.s24,
            AppSpace.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IkonBidang(
                    _ikonPengaturan(p),
                    warna: sudahSiap ? AppColors.sukses : AppColors.aksenTeks,
                    latar: sudahSiap
                        ? AppColors.suksesLembut
                        : AppColors.aksenLembut,
                  ),
                  const SizedBox(width: AppSpace.s12),
                  Expanded(
                    child: Text('PENGATURAN HP', style: AppText.penanda),
                  ),
                  IconButton(
                    tooltip: 'Tutup pengaturan',
                    onPressed: () => Navigator.pop(lembar, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s20),
              Semantics(
                header: true,
                child: Text(p.judul, style: AppText.judul),
              ),
              const SizedBox(height: AppSpace.s8),
              Text(
                sudahSiap ? p.saatSiap : p.saatBelum,
                style: AppText.kecilTebal.copyWith(
                  color: sudahSiap ? AppColors.sukses : AppColors.bahaya,
                ),
              ),
              const SizedBox(height: AppSpace.s24),
              Text('Cara mengatur', style: AppText.label),
              const SizedBox(height: AppSpace.s8),
              Container(
                padding: const EdgeInsets.all(AppSpace.s16),
                decoration: const BoxDecoration(
                  color: AppColors.aksenLembut,
                  borderRadius: AppRadius.brKartu,
                ),
                child: Text(p.langkah, style: AppText.isi),
              ),
              const SizedBox(height: AppSpace.s16),
              Text(
                'Ini simulasi. Tombol di bawah tidak mengubah izin atau '
                'pengaturan HP Anda.',
                style: AppText.kecil,
              ),
              if (p == PengaturanHp.mulaiOtomatis) ...[
                const SizedBox(height: AppSpace.s8),
                Text(
                  'Letak menu Mulai otomatis dapat berbeda menurut merek HP.',
                  style: AppText.kecil,
                ),
              ],
              const SizedBox(height: AppSpace.s24),
              Tombol(
                sudahSiap ? 'Tutup' : 'Simulasikan sudah diatur',
                onTap: () => Navigator.pop(lembar, !sudahSiap),
              ),
            ],
          ),
        ),
      ),
    );
    if (context.mounted && hasil == true) {
      await AppScope.baca(context).tandaiSiap(p);
    }
  }

  Widget _tombolLanjut(BuildContext context, bool siap, bool adaTruk) =>
      Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s20,
          AppSpace.s12,
          AppSpace.s20,
          AppSpace.s16,
        ),
        decoration: const BoxDecoration(
          color: AppColors.permukaan,
          borderRadius: AppRadius.brLogin,
          border: Border.fromBorderSide(BorderSide(color: AppColors.garis)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tombol(
              'Lanjut',
              onTap: siap
                  ? () => buka(
                      context,
                      adaTruk ? NamaRute.beranda : NamaRute.pilihTruk,
                      ganti: true,
                    )
                  : null,
            ),
            if (!siap) ...[
              const SizedBox(height: AppSpace.s8),
              Text(
                'Lengkapi kelima pengaturan untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: AppText.mikro,
              ),
            ],
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.latar,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: s.truk != null
            ? IconButton(
                tooltip: 'Kembali',
                onPressed: () => buka(context, NamaRute.beranda, ganti: true),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        title: const Text('Kesiapan HP'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpace.s12),
            child: LogoPerusahaan(ringkas: true),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, batas) {
            final tombolTetap =
                batas.maxHeight >= 580 &&
                MediaQuery.textScalerOf(context).scale(15) <= 19.5;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.s24,
                      AppSpace.s8,
                      AppSpace.s24,
                      AppSpace.s20,
                    ),
                    children: [
                      _IlustrasiKesiapan(siap: s.semuaSiap),
                      const SizedBox(height: AppSpace.s12),
                      Semantics(
                        header: true,
                        child: Text(
                          'Siapkan HP Anda',
                          textAlign: TextAlign.center,
                          style: AppText.subjudulBesar,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s8),
                      Text(
                        'Ketuk kartu untuk melihat cara menyiapkannya.',
                        textAlign: TextAlign.center,
                        style: AppText.kecil,
                      ),
                      const SizedBox(height: AppSpace.s24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'KESIAPAN PERANGKAT',
                              style: AppText.penanda,
                            ),
                          ),
                          Text(
                            '${s.jumlahSiap}/${s.jumlahPengaturan}',
                            style: AppText.nomorTruk.copyWith(
                              color: s.semuaSiap
                                  ? AppColors.sukses
                                  : AppColors.aksenTeks,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.s8),
                      ClipRRect(
                        borderRadius: AppRadius.brChip,
                        child: LinearProgressIndicator(
                          minHeight: AppUkuran.batangProgres,
                          value: s.jumlahSiap / s.jumlahPengaturan,
                          backgroundColor: AppColors.nonaktif,
                          color: s.semuaSiap
                              ? AppColors.sukses
                              : AppColors.aksen,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s20),
                      LayoutBuilder(
                        builder: (context, lebar) {
                          final sempit =
                              lebar.maxWidth < 290 ||
                              MediaQuery.textScalerOf(context).scale(15) > 21;
                          final lebarKartu = sempit
                              ? lebar.maxWidth
                              : (lebar.maxWidth - AppSpace.s12) / 2;
                          return Wrap(
                            spacing: AppSpace.s12,
                            runSpacing: AppSpace.s12,
                            children: [
                              for (final p in PengaturanHp.values)
                                SizedBox(
                                  width: p == PengaturanHp.gps
                                      ? lebar.maxWidth
                                      : lebarKartu,
                                  child: _KartuPengaturan(
                                    pengaturan: p,
                                    siap: s.siap(p),
                                    lebarPenuh: p == PengaturanHp.gps || sempit,
                                    onTap: () => _atur(context, p),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpace.s20),
                      const IndikatorDemo(),
                      if (!tombolTetap) ...[
                        const SizedBox(height: AppSpace.s16),
                        _tombolLanjut(context, s.semuaSiap, s.truk != null),
                      ],
                    ],
                  ),
                ),
                if (tombolTetap)
                  _tombolLanjut(context, s.semuaSiap, s.truk != null),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KartuPengaturan extends StatelessWidget {
  const _KartuPengaturan({
    required this.pengaturan,
    required this.siap,
    required this.lebarPenuh,
    required this.onTap,
  });
  final PengaturanHp pengaturan;
  final bool siap, lebarPenuh;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '${pengaturan.judul}, ${siap ? 'siap' : 'perlu diatur'}',
    child: Material(
      color: AppColors.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.brKartu,
        side: BorderSide(color: AppColors.garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s16),
          child: lebarPenuh
              ? Row(
                  children: [
                    _ikon(),
                    const SizedBox(width: AppSpace.s12),
                    Expanded(child: _label()),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: AppUkuran.ikonKecil,
                      color: AppColors.teksSekunder,
                    ),
                  ],
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 116),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpace.s8,
                    children: [_ikon(), _label()],
                  ),
                ),
        ),
      ),
    ),
  );

  Widget _ikon() => IkonBidang(
    _ikonPengaturan(pengaturan),
    ringkas: true,
    warna: siap ? AppColors.sukses : AppColors.aksenTeks,
    latar: siap ? AppColors.suksesLembut : AppColors.aksenLembut,
  );

  Widget _label() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        pengaturan.judul,
        style: AppText.label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: AppSpace.s4),
      Text(
        siap ? 'Siap' : 'Perlu diatur',
        style: AppText.kecilTebal.copyWith(
          color: siap ? AppColors.sukses : AppColors.bahaya,
        ),
      ),
    ],
  );
}

class _IlustrasiKesiapan extends StatelessWidget {
  const _IlustrasiKesiapan({required this.siap});
  final bool siap;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Center(
      child: SizedBox(
        width: 160,
        height: 104,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: AppUkuran.lingkaranSelesai,
              height: AppUkuran.lingkaranSelesai,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.aksenLembut, AppColors.permukaan],
                ),
              ),
              child: const Icon(
                Icons.phonelink_setup_rounded,
                size: AppUkuran.ikonRaksasa,
                color: AppColors.aksen,
              ),
            ),
            const Positioned(
              left: 0,
              top: AppSpace.s8,
              child: IkonBidang(Icons.settings_outlined, ringkas: true),
            ),
            Positioned(
              right: 0,
              bottom: AppSpace.s8,
              child: IkonBidang(
                siap ? Icons.check_rounded : Icons.gps_fixed_rounded,
                warna: AppColors.teksTerbalik,
                latar: siap ? AppColors.sukses : AppColors.gelap,
                ringkas: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
