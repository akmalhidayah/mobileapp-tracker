import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/nama_rute.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_ukuran.dart';
import '../../core/widgets/komponen.dart';
import '../../core/widgets/animasi_rute.dart';
import '../masuk/layar_masuk.dart';
import '../../core/widgets/visual_identitas.dart';

/// Halaman pembuka sebelum pengguna mengisi nomor HP dan PIN.
class LayarAwal extends StatefulWidget {
  const LayarAwal({super.key, this.bukaLogin = false});
  final bool bukaLogin;

  @override
  State<LayarAwal> createState() => _LayarAwalState();
}

class _LayarAwalState extends State<LayarAwal> {
  bool _loginTerbuka = false;
  int _ketukLogo = 0;

  @override
  void initState() {
    super.initState();
    if (widget.bukaLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          _bukaLogin();
        }
      });
    }
  }

  Future<void> _bukaLogin() async {
    if (_loginTerbuka) return;
    setState(() => _loginTerbuka = true);
    try {
      final kurangiGerak = MediaQuery.disableAnimationsOf(context);
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: AppColors.permukaan,
        barrierColor: AppColors.gelap.withValues(alpha: 0.26),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brLogin),
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width,
          maxWidth: MediaQuery.sizeOf(context).width,
        ),
        sheetAnimationStyle: AnimationStyle(
          duration: kurangiGerak
              ? Duration.zero
              : const Duration(milliseconds: 400),
          reverseDuration: kurangiGerak
              ? Duration.zero
              : const Duration(milliseconds: 260),
        ),
        builder: (_) => const FormMasuk(),
      );
    } finally {
      if (mounted) setState(() => _loginTerbuka = false);
    }
  }

  void _bukaDebug() {
    if (kDebugMode && ++_ketukLogo == 5) {
      _ketukLogo = 0;
      buka(context, NamaRute.debug);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.permukaan,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, batas) {
          // Tetap dapat digulir pada HP pendek, landscape, atau teks besar.
          final tinggiFoto = (batas.maxHeight * 0.62).clamp(280.0, 600.0);
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: batas.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: tinggiFoto,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/bg_start.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          excludeFromSemantics: true,
                        ),
                        // Putih transparan menjaga warna foto saat bertransisi
                        // ke permukaan putih, tanpa garis pemisah.
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.permukaan.withValues(alpha: 0),
                                AppColors.permukaan.withValues(alpha: 0),
                                AppColors.permukaan.withValues(alpha: 0.7),
                                AppColors.permukaan,
                              ],
                              stops: const [0, 0.55, 0.84, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          top: tinggiFoto * 0.2,
                          left: AppSpace.s24,
                          right: AppSpace.s24,
                          height: tinggiFoto * 0.38,
                          child: const AnimasiRute(),
                        ),
                        Positioned(
                          top: AppSpace.s16,
                          right: AppSpace.s16,
                          child: LogoPerusahaan(onTap: _bukaDebug),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.s24,
                      AppSpace.s8,
                      AppSpace.s24,
                      AppSpace.s24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'TRACKER TRUK · SEMEN TONASA',
                          textAlign: TextAlign.center,
                          style: AppText.penanda.copyWith(
                            color: AppColors.aksenTeks,
                          ),
                        ),
                        const SizedBox(height: AppSpace.s12),
                        Semantics(
                          header: true,
                          child: Text(
                            'Setiap perjalanan,\nlebih terarah.',
                            textAlign: TextAlign.center,
                            style: AppText.judulBesar,
                          ),
                        ),
                        const SizedBox(height: AppSpace.s32),
                        FilledButton(
                          onPressed: _loginTerbuka ? null : _bukaLogin,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, AppUkuran.tombol),
                            padding: const EdgeInsets.all(AppSpace.s16),
                            backgroundColor: AppColors.aksen,
                            foregroundColor: AppColors.teks,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.brChip,
                            ),
                            textStyle: AppText.tombol,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(child: Text('Mulai')),
                              SizedBox(width: AppSpace.s12),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: AppUkuran.ikonKecil,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
