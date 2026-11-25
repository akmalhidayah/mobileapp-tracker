# Ringkasan proyek Tracker Clinker Tonasa

Audit proyek dilakukan pada **23 November 2026 (WITA)**. Peta file ada di [CODE_MAP.md](CODE_MAP.md). Panduan kerja ada di [AGENTS.md](AGENTS.md).

Tracker Clinker Tonasa mempunyai dua aplikasi. **Admin dan Vendor masuk melalui Django. Aplikasi supir dapat memakai API Django untuk login dan membaca penugasan nomor lambung. Posisi armada, ritase dan laporan masih memakai data simulasi.**

| Area | Sudah ada | Batas saat ini |
| --- | --- | --- |
| Login dashboard | Login/logout Django, profil, ganti kata sandi, dan User Panel untuk Admin. Vendor terikat pada satu Ekspeditur aktif. | Dashboard dijalankan secara lokal. |
| Data Master | Ekspeditur, truk, pengemudi, akun sopir, dan riwayat penugasan disimpan di SQLite. Admin dapat memberi beberapa nomor lambung untuk satu sopir. | API sopir membaca penugasan aktif dan armada aktif pada Ekspeditur sopir. |
| Monitoring web | Peta besar, ikon warna ekspeditur dan titik status, legenda tetap terlihat, pencarian, filter, daftar armada, detail truk, layar penuh, dan navigasi HP. | Posisi awal berasal dari fixture dan gerak ikon dihitung di browser. Truk baru tanpa fixture dapat muncul tanpa posisi. Tidak ada aliran GPS dari aplikasi supir. |
| Laporan web | Grafik vertikal dan garis ritase, total armada, tabel per ekspeditur, serta tabel harian horizontal dengan kalender WITA. | Grafik atas tetap cuplikan **17 November 2026 pukul 13.00 WITA**. Tabel harian memakai data **13–17 November 2026** dan memilih hari ini secara default. Pada tanggal tanpa data, kondisi kosong memang diharapkan. |
| Aplikasi supir | Login nomor HP dan PIN lewat API, persetujuan, cek kesiapan HP, pilihan truk sesuai penugasan, sesi, peta, pengiriman simulasi, dan laporan sesi. | Token login, data sesi simulasi, dan antrean berada di memori. QR tersedia pada mode demo lokal. Izin, baterai, GPS, dan konfirmasi kirim masih simulasi. |
| Rute bersama | Kedua proyek memakai rute demo Limestone Crusher 2 → Biringkassi. Dashboard menampilkan seluruh armada, Flutter menampilkan truk sesi supir. | Geometri disalin di Python dan Dart. Poligon muat/bongkar Flutter adalah ilustrasi untuk simulasi, sehingga belum boleh dipakai sebagai batas area operasional. |
| Distribusi | Aset ikon baru tersedia untuk dashboard, Flutter web, dan launcher Android. Perintah preview dan build tercatat di README masing-masing. | APK release memakai signing debug. Tidak ada klaim rilis produksi, pelacakan latar sungguhan, atau APK baru dari audit dokumentasi ini. |

## Keputusan yang perlu dijaga

- **Bedakan angka simulasi dan data aktual.** Dashboard memakai cuplikan riwayat yang diinput ke fixture. Flutter menampilkan estimasi muatan dari ritase × kapasitas truk, bukan hasil timbang. Jangan memakai keduanya sebagai data produksi tanpa sumber resmi.
- **Jaga arti waktu.** Tanggal harian dipilih menurut WITA. Waktu dashboard di header mengacu pada cuplikan di bagian atas, bukan tanggal yang dipilih untuk tabel harian. Suatu tanggal tanpa laporan tidak berarti nol produksi.
- **Samakan identitas sebelum menyambung data.** Nomor lambung membantu tampilan demo, tetapi integrasi perlu ID stabil untuk ekspeditur, supir, truk, penugasan, dan sesi. Contoh yang harus dibereskan: kode Prima Karya adalah `prima` di fixture dashboard dan `prima_karya` di Flutter.
- **Pisahkan posisi, status, dan hasil perjalanan.** Posisi terbaru, status operasi, keterlambatan pembaruan, dan ritase adalah hal berbeda. Pergerakan ikon, batas keterlambatan 10 menit di demo, serta durasi tunggu simulator tidak menetapkan aturan produksi.

## Rencana integrasi — 24 November 2026 (WITA)

Pekerjaan dimulai dari akun, hak akses, dan penugasan truk. Admin dan Vendor memakai login Django yang sudah berjalan. Sopir memakai login nomor HP dan PIN di Flutter, dengan validasi akun dan penugasan di Django. Fokus client mobile tahap pertama adalah menghubungkan layar login, sesi login, dan daftar truk ke kontrak tersebut. Pelacakan Android menyusul setelah sopir bisa memulai shift dengan truk yang ditugaskan.

- Saat bergerak, rekam GPS setiap **30 detik** dan kirim paket setiap **30 detik**. Saat diam, rekam GPS setiap **120 detik**. Dashboard Monitoring mengecek pembaruan setiap **30 detik**.
- Milestone integrasi pertama memakai **satu supir, satu truk, dan satu shift**. Admin memantau seluruh Ekspeditur. Vendor memantau dan mengisi laporan untuk Ekspeditur akunnya.

1. **Login supir dan penugasan truk sudah terhubung.** Admin mengaktifkan akun sopir, mereset PIN, dan mengatur penugasan dari Data Master. Supir masuk dengan nomor HP dan PIN enam digit. Django memverifikasi PIN dan mencabut token lama saat login baru. Aplikasi hanya menampilkan truk yang ditugaskan dari Django.
2. **Sesi shift dan pengiriman GPS.** Catat sesi mulai/selesai di Django. Kirim titik simulasi dengan ID sesi, nomor urut, timestamp GPS, dan akurasi. Cek Monitoring sebagai Admin, Vendor pemilik truk, dan Vendor lain. Uji kirim ulang paket untuk memastikan setiap titik tercatat sekali.
3. **Laporan Vendor tersimpan permanen.** Simpan laporan per Ekspeditur dan tanggal WITA agar Vendor bisa membukanya setelah login ulang dan Admin bisa melihat laporan seluruh Ekspeditur. Catat input manual Vendor secara terpisah dari ritase hasil hitung server.
4. **GPS Android sungguhan.** Hubungkan modul Kotlin ke alur sesi Flutter. Uji izin, layar terkunci, penghemat baterai, kehilangan jaringan, pengiriman ulang, dan pemulihan setelah restart di HP fisik. Cocokkan ritase dengan batas area, durasi muat/bongkar, dan catatan lapangan sebelum rilis.

Persiapan rilis mencakup konfigurasi server dan basis data, pengamanan akun, kebijakan akses dan retensi GPS, penyedia tile, serta signing Android.

## Pemeriksaan dan repositori

- Versi lokal yang ditemukan: Python **3.12.16**, Django **5.2.19**, Node **22.23.5**, Flutter **3.50.0**, dan Dart **3.14.0**. Paket React dan Flutter punya lockfile; `requirements.txt` mengizinkan Django seri 5.2.
- Saat audit, `manage.py check` lulus, tidak ada perubahan model tanpa migrasi menurut `makemigrations --check --dry-run`, dan migrasi Monitoring `0001` sampai `0003` sudah tercatat di SQLite lokal.
- Suite Flutter sudah tersedia. Audit ini tidak menjalankan suite Flutter, membangun ulang APK/web, atau menguji perangkat nyata.
- Kode tersedia di [repo dashboard](https://github.com/akmalhidayah/web_tracker) dan [repo aplikasi supir](https://github.com/akmalhidayah/mobileapp-tracker).
- Panduan proyek: [README dashboard](https://github.com/akmalhidayah/web_tracker/blob/main/README.md) dan [README aplikasi supir](README.md). Hand-off dan aset mobile: [HANDOFF.md](docs/HANDOFF.md), [ASSETS.md](docs/ASSETS.md). Sebagian catatan lama memakai istilah “semen curah” atau menyebut HTMX; implementasi yang ditemukan sekarang adalah Django dengan React/Leaflet pada Monitoring.
