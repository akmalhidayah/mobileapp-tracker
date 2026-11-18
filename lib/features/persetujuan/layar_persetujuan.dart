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

const _informasi = [
  (
    ikon: Icons.location_on_outlined,
    judul: 'Data yang direkam',
    ringkas: 'Lokasi & status perangkat',
    rincian:
        'Selama sesi kerja, aplikasi merekam lokasi, waktu, kecepatan, '
        'arah, akurasi GPS, dan status baterai.',
    catatan: 'Data ini digunakan untuk mengikuti perjalanan truk selama sesi.',
  ),
  (
    ikon: Icons.schedule_rounded,
    judul: 'Waktu perekaman',
    ringkas: 'Hanya selama sesi aktif',
    rincian:
        'Perekaman baru dimulai setelah Anda menekan Mulai sesi kerja '
        'dan berhenti saat Anda menyelesaikan sesi.',
    catatan:
        'Sesi berhenti otomatis pada 16 jam. Tidak ada rekaman lokasi '
        'di luar sesi kerja.',
  ),
  (
    ikon: Icons.insights_outlined,
    judul: 'Penggunaan data',
    ringkas: 'Perjalanan & perhitungan ritase',
    rincian: 'Data digunakan untuk memantau perjalanan dan menghitung ritase.',
    catatan:
        'Masa simpan mengikuti kebijakan perusahaan yang belum ditetapkan '
        'untuk demo. Data demo dapat hilang saat aplikasi dimuat ulang.',
  ),
  (
    ikon: Icons.lock_outline_rounded,
    judul: 'Yang tidak direkam',
    ringkas: 'Kontak, foto & pesan pribadi',
    rincian:
        'Aplikasi tidak merekam kontak, foto, pesan, atau aktivitas '
        'pribadi lainnya.',
    catatan: 'Tidak ada rekaman lokasi di luar sesi kerja.',
  ),
];

class LayarPersetujuan extends StatefulWidget {
  const LayarPersetujuan({super.key});
  @override
  State<LayarPersetujuan> createState() => _LayarPersetujuanState();
}

class _LayarPersetujuanState extends State<LayarPersetujuan> {
  bool setuju = false;
  bool _rincianTerbuka = false;

  Future<void> _bacaRincian(int indeks) async {
    if (_rincianTerbuka) return;
    _rincianTerbuka = true;
    final item = _informasi[indeks];
    try {
      await showModalBottomSheet<void>(
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
                    IkonBidang(item.ikon),
                    const SizedBox(width: AppSpace.s12),
                    Expanded(
                      child: Text(
                        'PRIVASI · ${indeks + 1} DARI ${_informasi.length}',
                        style: AppText.penanda,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tutup rincian',
                      onPressed: () => Navigator.pop(lembar),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s24),
                Semantics(
                  header: true,
                  child: Text(item.judul, style: AppText.judul),
                ),
                const SizedBox(height: AppSpace.s16),
                Text(item.rincian, style: AppText.isiBesar),
                const SizedBox(height: AppSpace.s20),
                Container(
                  padding: const EdgeInsets.all(AppSpace.s16),
                  decoration: const BoxDecoration(
                    color: AppColors.aksenLembut,
                    borderRadius: AppRadius.brKartu,
                  ),
                  child: Text(item.catatan, style: AppText.isi),
                ),
                const SizedBox(height: AppSpace.s24),
                Tombol('Mengerti', onTap: () => Navigator.pop(lembar)),
              ],
            ),
          ),
        ),
      );
    } finally {
      _rincianTerbuka = false;
    }
  }

  void _tolak() {
    if (AppScope.baca(context).keluar()) {
      buka(context, NamaRute.awal, ganti: true);
    }
  }

  Widget _pilihanPersetujuan() => Container(
    padding: const EdgeInsets.fromLTRB(
      AppSpace.s20,
      AppSpace.s8,
      AppSpace.s20,
      AppSpace.s8,
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
        KotakCentang(
          nilai: setuju,
          teks:
              'Saya memahami dan menyetujui penggunaan data selama sesi kerja.',
          onChanged: (v) => setState(() => setuju = v),
        ),
        Tombol(
          'Setuju dan lanjut',
          onTap: setuju
              ? () {
                  AppScope.baca(context).setuju();
                  buka(context, NamaRute.kesiapan, ganti: true);
                }
              : null,
        ),
        TextButton(onPressed: _tolak, child: const Text('Tidak setuju')),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.latar,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Persetujuan'),
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
          // Pada layar pendek/teks besar semua konten ikut digulir supaya
          // panel pilihan tidak menghabiskan ruang untuk membaca kartu.
          final pilihanTetap =
              batas.maxHeight >= 600 &&
              MediaQuery.textScalerOf(context).scale(15) <= 19.5;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.s24,
                    AppSpace.s8,
                    AppSpace.s24,
                    AppSpace.s16,
                  ),
                  children: [
                    const _IlustrasiPrivasi(),
                    const SizedBox(height: AppSpace.s12),
                    Semantics(
                      header: true,
                      child: Text(
                        'Privasi Anda penting',
                        textAlign: TextAlign.center,
                        style: AppText.subjudulBesar,
                      ),
                    ),
                    const SizedBox(height: AppSpace.s8),
                    Text(
                      'Kenali penggunaan data Anda.\nKetuk kartu untuk membaca rinciannya.',
                      textAlign: TextAlign.center,
                      style: AppText.kecil,
                    ),
                    const SizedBox(height: AppSpace.s20),
                    for (var i = 0; i < _informasi.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.s8),
                        child: _KartuPrivasi(
                          indeks: i,
                          onTap: () => _bacaRincian(i),
                        ),
                      ),
                    const SizedBox(height: AppSpace.s8),
                    const IndikatorDemo(),
                    if (!pilihanTetap) ...[
                      const SizedBox(height: AppSpace.s16),
                      _pilihanPersetujuan(),
                    ],
                  ],
                ),
              ),
              if (pilihanTetap) _pilihanPersetujuan(),
            ],
          );
        },
      ),
    ),
  );
}

class _KartuPrivasi extends StatelessWidget {
  const _KartuPrivasi({required this.indeks, required this.onTap});
  final int indeks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = _informasi[indeks];
    return Semantics(
      button: true,
      hint: 'Buka rincian ${item.judul.toLowerCase()}',
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
                IkonBidang(item.ikon, ringkas: true),
                const SizedBox(width: AppSpace.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.judul, style: AppText.label),
                      const SizedBox(height: AppSpace.s4),
                      Text(item.ringkas, style: AppText.kecil),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.s8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: AppUkuran.ikonKecil,
                  color: AppColors.teksSekunder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IlustrasiPrivasi extends StatelessWidget {
  const _IlustrasiPrivasi();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Center(
      child: SizedBox(
        width: 160,
        height: 112,
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
                Icons.verified_user_rounded,
                size: AppUkuran.ikonRaksasa,
                color: AppColors.aksen,
              ),
            ),
            const Positioned(
              left: 0,
              top: AppSpace.s8,
              child: IkonBidang(Icons.lock_outline_rounded, ringkas: true),
            ),
            const Positioned(
              right: 0,
              bottom: AppSpace.s8,
              child: IkonBidang(
                Icons.location_on_outlined,
                warna: AppColors.teksTerbalik,
                latar: AppColors.gelap,
                ringkas: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
