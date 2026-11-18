import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/nama_rute.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_ukuran.dart';
import '../../core/widgets/komponen.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/supir.dart';
import '../../state/app_state.dart';

class FormMasuk extends StatefulWidget {
  const FormMasuk({super.key});
  @override
  State<FormMasuk> createState() => _FormMasukState();
}

class _FormMasukState extends State<FormMasuk> {
  final _form = GlobalKey<FormState>();
  final _hp = TextEditingController(), _pin = TextEditingController();
  @override
  void dispose() {
    _hp.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _masuk() {
    if (!_form.currentState!.validate()) return;
    if (AppScope.baca(context).masuk(noHp: _hp.text, pin: _pin.text)) {
      _pin.clear();
      FocusScope.of(context).unfocus();
      buka(context, NamaRute.persetujuan, ganti: true);
    }
  }

  Widget _kolom(
    String label,
    IconData ikon,
    TextEditingController isi,
    bool rahasia,
    String? Function(String?) validator,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.s12),
    child: TextFormField(
      controller: isi,
      obscureText: rahasia,
      keyboardType: rahasia ? TextInputType.number : TextInputType.phone,
      textInputAction: rahasia ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: (_) {
        if (rahasia) _masuk();
      },
      autocorrect: false,
      enableSuggestions: false,
      validator: validator,
      style: AppText.isi,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(ikon, color: AppColors.oranyeMasukTeks),
        filled: true,
        fillColor: AppColors.oranyeMasukLembut,
        contentPadding: const EdgeInsets.all(AppSpace.s16),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.brInput,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brInput,
          borderSide: BorderSide(color: AppColors.garis),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.brInput,
          borderSide: BorderSide(color: AppColors.oranyeMasukTeks, width: 2),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => AnimatedPadding(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200),
    curve: Curves.easeOut,
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s24,
        AppSpace.s8,
        AppSpace.s24,
        AppSpace.s24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SELAMAT DATANG KEMBALI',
                    style: AppText.penanda.copyWith(color: AppColors.aksenTeks),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup login',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Text('Siap memulai perjalanan?', style: AppText.judul),
            const SizedBox(height: AppSpace.s8),
            Text('Masuk dengan nomor HP dan PIN Anda.', style: AppText.kecil),
            const SizedBox(height: AppSpace.s24),
            Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _kolom('Nomor HP', Icons.phone_outlined, _hp, false, (v) {
                    if (!AppState.hpValid(v ?? '')) {
                      return 'Masukkan nomor HP 10–15 digit.';
                    }
                    return AppState.cariAkun(v!) == null
                        ? 'Nomor HP belum terdaftar. Hubungi admin vendor.'
                        : null;
                  }),
                  _kolom(
                    'PIN 6 digit',
                    Icons.lock_outline,
                    _pin,
                    true,
                    (v) => AppState.pinValid(v ?? '')
                        ? null
                        : 'PIN harus tepat 6 digit angka.',
                  ),
                  const SizedBox(height: AppSpace.s4),
                  FilledButton(
                    onPressed: _masuk,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, AppUkuran.tombol),
                      padding: const EdgeInsets.all(AppSpace.s16),
                      backgroundColor: AppColors.oranyeMasuk,
                      foregroundColor: AppColors.teks,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.brChip,
                      ),
                      textStyle: AppText.tombol,
                    ),
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.s20),
            Text(
              'AKUN DEMO · ketuk untuk mengisi nomor',
              style: AppText.penanda,
            ),
            const SizedBox(height: AppSpace.s8),
            for (final akun in DummyData.akunSupir)
              _BarisAkunDemo(
                akun: akun,
                onTap: () => setState(() => _hp.text = akun.noHp),
              ),
            Text('PIN bebas, asalkan 6 digit angka.', style: AppText.mikro),
            const SizedBox(height: AppSpace.s16),
            Text(
              'Lupa PIN? Hubungi admin perusahaan.',
              textAlign: TextAlign.center,
              style: AppText.kecil,
            ),
            const SizedBox(height: AppSpace.s16),
            const IndikatorDemo(),
          ],
        ),
      ),
    ),
  );
}

class _BarisAkunDemo extends StatelessWidget {
  const _BarisAkunDemo({required this.akun, required this.onTap});
  final Supir akun;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: AppRadius.brTombolKecil,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppUkuran.targetSentuh),
      child: Row(
        children: [
          const Icon(
            Icons.business_rounded,
            size: AppUkuran.ikonKecil,
            color: AppColors.aksenTeks,
          ),
          const SizedBox(width: AppSpace.s8),
          Expanded(
            child: Text(
              '${akun.vendor.namaSingkat} · ${akun.nama}',
              style: AppText.kecilTebal,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(akun.noHp, style: AppText.kecil),
        ],
      ),
    ),
  );
}
