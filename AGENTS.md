# Panduan kerja aplikasi supir Tracker Clinker Tonasa

Panduan ini berlaku dari akar repositori. Gunakan [CODE_MAP.md](CODE_MAP.md) untuk mencari kode dan [RINGKASAN.md](RINGKASAN.md) untuk melihat status fitur serta integrasi.

Pertahankan istilah yang sudah dipilih di antarmuka, seperti **Tracker Clinker Tonasa**, **nomor lambung**, **ritase**, dan tanggal laporan dalam **WITA**. Dashboard memakai **Ekspeditur**. Masing-masing target memiliki proses build dan preview sendiri.

Dashboard admin tersedia di [web_tracker](https://github.com/akmalhidayah/web_tracker).

## Aplikasi supir

- Ikuti batas versi SDK di `pubspec.yaml` dan gunakan dependensi dari `pubspec.lock`. Perubahan tampilan biasanya dapat dikerjakan dengan versi Flutter, Dart, dan Gradle yang sudah digunakan.
- Untuk verifikasi perangkat, ikuti arahan pengguna jika pengujian akan dilakukan manual. Jalankan build Flutter atau Gradle secara bergantian.
- Jaga alur melalui `AppState` dan `AppScope`; logika GPS, upload, dan ritase simulasi berada di lapisan layanan. Jangan memulai tracking dari widget, melewati persetujuan/kesiapan, atau mengizinkan ganti truk/logout saat sesi aktif.
- Pertahankan beda antara **estimasi muatan** (ritase × kapasitas) dan berat aktual. Jangan menganggap ACK simulasi sebagai bukti data masuk ke server sungguhan.
- Bila rute demo berubah, cocokkan titik dan urutan koordinat di kedua proyek. Vendor dan akun Flutter tetap data lokal sampai ada kontrak integrasi.
- Untuk mengganti ikon, gunakan master `assets/branding/app_icon.png` dan skrip `scripts/generate_icons_macos.sh`. Untuk mengubah logo perusahaan, cek pemakaiannya di `lib/core/widgets/visual_identitas.dart`. Ikon merek, logo perusahaan, dan penanda peta adalah aset berbeda.

Jalankan pemeriksaan yang relevan dari akar repositori:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Perintah build untuk dijalankan terpisah sesuai kebutuhan:

```sh
# Pratinjau web
flutter build web --no-wasm-dry-run --no-web-resources-cdn
python3 -m http.server 8732 --bind 127.0.0.1 --directory build/web

# APK Android
flutter build apk --release
```

Jangan menjalankan lagi server port 8732 jika sudah melayani `build/web`. Jika ikon atau tampilan pratinjau masih lama, pastikan build sudah selesai lalu refresh keras. APK berada di `build/app/outputs/flutter-apk/app-release.apk`; signing saat ini untuk demo. Lihat [README aplikasi supir](README.md) untuk setup SDK dan skenario simulasi.
