# Aset ilustrasi armada

## Ikon aplikasi dan favicon

- Sumber pengguna: `../icon.png`; salinan master di `assets/branding/app_icon.png`.
- Gambar asli diperkecil dengan `sips`, tanpa menggambar ulang logo.
- Android: ikon legacy 48/72/96/144/192 px dan lapisan adaptive 108/162/216/324/432 px.
- Web: favicon 32 px, Apple touch icon 180 px, ikon instalasi 192/512 px,
  serta varian maskable dengan jarak tepi tambahan.
- Regenerasi pada Mac: `bash scripts/generate_icons_macos.sh` dari aplikasi_supir.
- Rujukan area aman: [Android adaptive icons](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive)
  dan [MDN maskable icons](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/How_to/Define_app_icons).

## Foto halaman pembuka

Halaman start memakai `assets/images/bg_start.png` sesuai koreksi pengguna.
Panel login terbuka di atas halaman ini. Animasi rute dengan truk bergerak
dibuat melalui `CustomPainter` di `lib/core/widgets/animasi_rute.dart`, tanpa
aset unduhan. `bg_login.png` tetap disimpan sebagai aset alternatif.

- Sumber pengguna: `../start-bg.avif`, foto pabrik, 1280 × 755.
- Aset aplikasi: `assets/images/bg_start.png`, konversi format dengan `sips`.
- Gradasi menuju putih dibuat oleh widget Flutter di `LayarAwal`; foto sumber
  tetap utuh. Logo memakai komponen bersama `LogoPerusahaan`.

## Ilustrasi truk

- Berkas: `assets/images/truk_tambang.png`
- Dibuat 17 November 2026 dengan tool bawaan `image_gen.imagegen`.
- PNG transparan 1536 × 1024, dipakai pada pilihan truk, beranda, dan sesi aktif.
- Ilustrasi generik untuk demo; bukan foto atau identifikasi unit kendaraan asli.
- Logo SIG dan Semen Tonasa memakai aset asli yang sudah ada, bukan hasil generasi.

## Prompt final

```text
Use case: stylized-concept. Asset type: transparent cutout hero illustration for a professional Indonesian mining truck driver mobile app. Create ONE clean premium 3D product render of an orange-yellow heavy rigid mining dump truck, three-quarter front view facing toward the lower left. Clearly recognizable large dump bed lowered in driving position, sturdy cab, dark charcoal chassis, four visible chunky black rubber tires, tasteful realistic industrial details, light blue dark tinted glass. Entire vehicle visible, centered, tight useful framing with small transparent margins. Soft studio illumination, crisp silhouette, restrained realistic materials, friendly polished app illustration matching a clean orange and white interface. True transparent background, no environment, no floor, no panel, no text, no logo, no watermark, no other vehicles, no people. Landscape composition, vehicle should occupy most of canvas width. This is a standalone app image, not a screenshot or UI mockup.
```
