import 'package:material_ui/material_ui.dart';

import 'visual_identitas.dart';
import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../data/models/truk.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_space.dart';
import '../theme/app_text.dart';
import '../theme/app_ukuran.dart';

void buka(BuildContext context, String rute, {bool ganti = false}) {
  if (ganti) {
    Navigator.of(context).pushNamedAndRemoveUntil(rute, (_) => false);
  } else {
    Navigator.of(context).pushNamed(rute);
  }
}

void pesan(BuildContext context, String teks) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(teks)));

class Layar extends StatelessWidget {
  const Layar({
    super.key,
    required this.judul,
    required this.children,
    this.kembali = false,
    this.aksi,
    this.logo = false,
    this.judulVendorUtama = false,
    this.tampilkanIndikatorDemo = true,
  });
  final String judul;
  final List<Widget> children;
  final bool kembali;
  final Widget? aksi;
  final bool logo;
  final bool judulVendorUtama;
  final bool tampilkanIndikatorDemo;
  @override
  Widget build(BuildContext context) {
    final vendor = AppScope.of(context).supir?.vendor.nama;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: vendor == null ? null : AppUkuran.headerVendor,
        leading: kembali
            ? IconButton(
                tooltip: 'Kembali',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                  } else {
                    buka(
                      context,
                      AppScope.baca(context).ruteSemestinya,
                      ganti: true,
                    );
                  }
                },
              )
            : null,
        title: vendor != null && judulVendorUtama
            ? Text(
                vendor,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.nomorTruk,
              )
            : vendor == null
            ? Text(judul)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(judul, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpace.s4),
                  Row(
                    children: [
                      const Icon(
                        Icons.business_rounded,
                        size: AppUkuran.ikonKecil,
                        color: AppColors.aksenTeks,
                      ),
                      const SizedBox(width: AppSpace.s4),
                      Expanded(
                        child: Text(
                          vendor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.kecilTebal.copyWith(
                            color: AppColors.aksenTeks,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          ?aksi,
          if (logo)
            const Padding(
              padding: EdgeInsets.only(right: AppSpace.s12),
              child: LogoPerusahaan(ringkas: true),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.layar),
          children: [
            ...children,
            const SizedBox(height: AppSpace.s24),
            if (tampilkanIndikatorDemo) const IndikatorDemo(),
          ],
        ),
      ),
    );
  }
}

class IndikatorDemo extends StatelessWidget {
  const IndikatorDemo({super.key});
  @override
  Widget build(BuildContext context) => Text(
    'Mode demo · data simulasi\nData dapat hilang saat refresh / restart.',
    textAlign: TextAlign.center,
    style: AppText.mikro,
  );
}

class Tombol extends StatelessWidget {
  const Tombol(
    this.teks, {
    super.key,
    this.onTap,
    this.sekunder = false,
    this.bahaya = false,
    this.sibuk = false,
    this.ikon,
  });
  final String teks;
  final VoidCallback? onTap;
  final bool sekunder, bahaya, sibuk;
  final IconData? ikon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpace.s8),
    child: SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: sibuk ? null : onTap,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppUkuran.tombol),
          padding: const EdgeInsets.all(AppSpace.s16),
          backgroundColor: bahaya
              ? AppColors.bahaya
              : sekunder
              ? AppColors.permukaan
              : AppColors.aksen,
          foregroundColor: bahaya ? AppColors.teksTerbalik : AppColors.teks,
          disabledBackgroundColor: AppColors.nonaktif,
          disabledForegroundColor: AppColors.teksNonaktif,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.brTombol,
            side: sekunder
                ? const BorderSide(color: AppColors.garis)
                : BorderSide.none,
          ),
          textStyle: AppText.tombol,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpace.s8,
          children: [
            if (sibuk)
              const SizedBox(
                width: AppUkuran.ikonKecil,
                height: AppUkuran.ikonKecil,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (ikon != null && !sibuk) Icon(ikon),
            Text(teks, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class TombolKecil extends StatelessWidget {
  const TombolKecil(this.teks, {super.key, this.onTap});
  final String teks;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      minimumSize: const Size(AppUkuran.targetSentuh, AppUkuran.targetSentuh),
      foregroundColor: AppColors.aksenTeks,
    ),
    child: Text(teks),
  );
}

class KartuInfo extends StatelessWidget {
  const KartuInfo({
    super.key,
    required this.child,
    this.warna = AppColors.permukaan,
  });
  final Widget child;
  final Color warna;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpace.s12),
    padding: const EdgeInsets.all(AppSpace.s16),
    decoration: BoxDecoration(
      color: warna,
      borderRadius: AppRadius.brKartu,
      border: Border.all(color: AppColors.garis),
    ),
    child: child,
  );
}

class InputBerlabel extends StatelessWidget {
  const InputBerlabel({
    super.key,
    required this.label,
    required this.controller,
    this.rahasia = false,
    this.validator,
    this.onSubmit,
  });
  final String label;
  final TextEditingController controller;
  final bool rahasia;
  final String? Function(String?)? validator;
  final VoidCallback? onSubmit;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.s16),
    child: TextFormField(
      controller: controller,
      obscureText: rahasia,
      keyboardType: rahasia ? TextInputType.number : TextInputType.phone,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: rahasia ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: (_) => onSubmit?.call(),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.permukaan,
        contentPadding: const EdgeInsets.all(AppSpace.s16),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.brInput,
          borderSide: BorderSide(color: AppColors.garisKuat),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brInput,
          borderSide: BorderSide(color: AppColors.aksenTeks, width: 2),
        ),
      ),
    ),
  );
}

class KotakCentang extends StatelessWidget {
  const KotakCentang({
    super.key,
    required this.nilai,
    required this.teks,
    required this.onChanged,
  });
  final bool nilai;
  final String teks;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    activeColor: AppColors.aksen,
    checkColor: AppColors.teks,
    value: nilai,
    onChanged: (v) => onChanged(v ?? false),
    title: Text(teks, style: AppText.isi),
  );
}

class BarisCek extends StatelessWidget {
  const BarisCek({
    super.key,
    required this.judul,
    required this.keterangan,
    required this.siap,
    required this.onAtur,
    this.ikon = Icons.settings_outlined,
  });
  final String judul, keterangan;
  final bool siap;
  final VoidCallback onAtur;
  final IconData ikon;
  @override
  Widget build(BuildContext context) => KartuInfo(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IkonBidang(
              ikon,
              warna: siap ? AppColors.sukses : AppColors.aksenTeks,
              latar: siap ? AppColors.suksesLembut : AppColors.aksenLembut,
            ),
            Positioned(
              right: -AppSpace.s4,
              bottom: -AppSpace.s4,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.permukaan,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.s4 / 2),
                  child: Icon(
                    siap ? Icons.check_circle_rounded : Icons.error_rounded,
                    size: AppUkuran.ikonKecil,
                    color: siap ? AppColors.sukses : AppColors.bahaya,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpace.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: AppText.label),
              const SizedBox(height: AppSpace.s4),
              Text(keterangan, style: AppText.kecil),
            ],
          ),
        ),
        TombolKecil('Atur', onTap: onAtur),
      ],
    ),
  );
}

class KartuTruk extends StatelessWidget {
  const KartuTruk({
    super.key,
    required this.truk,
    this.onGanti,
    this.namaVendor,
  });
  final Truk truk;
  final VoidCallback? onGanti;
  final String? namaVendor;
  @override
  Widget build(BuildContext context) => KartuInfo(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRUK ANDA', style: AppText.penanda),
                  const SizedBox(height: AppSpace.s4),
                  Text(truk.nomor, style: AppText.judul),
                  if (namaVendor != null)
                    Text(
                      namaVendor!,
                      style: AppText.kecilTebal.copyWith(
                        color: AppColors.aksenTeks,
                      ),
                    ),
                ],
              ),
            ),
            if (onGanti != null) TombolKecil('Ganti', onTap: onGanti),
          ],
        ),
        const SizedBox(height: AppSpace.s8),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: AppRadius.brKartu,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.aksenLembut, AppColors.permukaan],
            ),
          ),
          child: const IlustrasiTruk(tinggi: AppUkuran.ilustrasiTrukKartu),
        ),
        const SizedBox(height: AppSpace.s12),
        Wrap(
          spacing: AppSpace.s8,
          runSpacing: AppSpace.s4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: AppUkuran.ikonKecil,
              color: AppColors.aksenTeks,
            ),
            Text(truk.keterangan, style: AppText.kecil),
          ],
        ),
      ],
    ),
  );
}

class BarisTruk extends StatelessWidget {
  const BarisTruk({
    super.key,
    required this.truk,
    required this.onTap,
    this.namaVendor,
  });
  final Truk truk;
  final VoidCallback onTap;
  final String? namaVendor;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.s12),
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
          padding: const EdgeInsets.all(AppSpace.s12),
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.aksenLembut,
                  borderRadius: AppRadius.brInput,
                ),
                child: const IlustrasiTruk(
                  tinggi: AppUkuran.tombol,
                  lebar: AppUkuran.thumbnailTruk,
                ),
              ),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(truk.nomor, style: AppText.nomorTruk),
                    const SizedBox(height: AppSpace.s4),
                    Text(truk.keterangan, style: AppText.kecil),
                    if (namaVendor != null)
                      Text(
                        namaVendor!,
                        style: AppText.mikro.copyWith(
                          color: AppColors.aksenTeks,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: AppUkuran.ikonKecil,
                color: AppColors.aksenTeks,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ChipKesiapan extends StatelessWidget {
  const ChipKesiapan({super.key, required this.siap, required this.jumlah});
  final bool siap;
  final int jumlah;
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s16,
        vertical: AppSpace.s8,
      ),
      decoration: BoxDecoration(
        color: siap ? AppColors.suksesLembut : AppColors.bahayaLembut,
        borderRadius: AppRadius.brChip,
      ),
      child: Text(
        siap ? '✓  HP siap · 5/5' : 'HP belum siap · $jumlah/5',
        style: AppText.kecilTebal.copyWith(
          color: siap ? AppColors.sukses : AppColors.bahaya,
        ),
      ),
    ),
  );
}

class KartuStatistik extends StatelessWidget {
  const KartuStatistik({
    super.key,
    required this.label,
    required this.nilai,
    required this.ikon,
    this.warna = AppColors.aksenTeks,
    this.latarIkon = AppColors.aksenLembut,
  });
  final Color warna, latarIkon;
  final String label, nilai;
  final IconData ikon;
  @override
  Widget build(BuildContext context) => KartuInfo(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IkonBidang(ikon, warna: warna, latar: latarIkon, ringkas: true),
        const SizedBox(height: AppSpace.s8),
        Text(nilai, style: AppText.subjudulBesar),
        Text(label, style: AppText.kecil),
      ],
    ),
  );
}

class BannerPeringatan extends StatelessWidget {
  const BannerPeringatan(this.teks, {super.key, this.bahaya = false});
  final String teks;
  final bool bahaya;
  @override
  Widget build(BuildContext context) => KartuInfo(
    warna: bahaya ? AppColors.bahayaLembut : AppColors.aksenLembut,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          color: bahaya ? AppColors.bahaya : AppColors.aksenTeks,
        ),
        const SizedBox(width: AppSpace.s8),
        Expanded(
          child: Text(
            teks,
            style: AppText.kecil.copyWith(
              color: bahaya ? AppColors.bahaya : AppColors.aksenTeks,
            ),
          ),
        ),
      ],
    ),
  );
}

class BarisRingkasan extends StatelessWidget {
  const BarisRingkasan(this.label, this.nilai, {super.key});
  final String label, nilai;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: AppText.isi)),
        const SizedBox(width: AppSpace.s12),
        Flexible(
          child: Text(nilai, style: AppText.label, textAlign: TextAlign.end),
        ),
      ],
    ),
  );
}

class LogoMerek extends StatelessWidget {
  const LogoMerek({super.key, this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final aset in ['logo_semen_tonasa.png', 'logo_sig.png'])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s16),
            child: Image.asset(
              'assets/images/$aset',
              height: AppUkuran.logo,
              width: 100,
              fit: BoxFit.contain,
              semanticLabel: aset.startsWith('logo_sig')
                  ? 'SIG'
                  : 'Semen Tonasa',
              errorBuilder: (_, e, s) => const Text('Logo'),
            ),
          ),
      ],
    ),
  );
}

Widget tombolDebug(BuildContext context) => IconButton(
  tooltip: 'Debug simulasi',
  icon: const Icon(Icons.bug_report_outlined),
  onPressed: () => buka(context, NamaRute.debug),
);
