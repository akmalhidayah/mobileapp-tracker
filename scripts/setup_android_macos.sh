#!/usr/bin/env bash
# Menyiapkan Java + SDK untuk Mac Intel, tanpa Android Studio/emulator.
# Jalankan dari Terminal agar Anda dapat membaca/menyetujui lisensi SDK.
set -euo pipefail

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != x86_64 ]]; then
  echo 'Skrip ini khusus Mac Intel (x86_64).'
  exit 1
fi
if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter belum ada di PATH Terminal.'
  exit 1
fi
if [[ ! -t 0 ]]; then
  echo 'Jalankan skrip ini langsung di Terminal untuk membaca lisensi SDK.'
  exit 1
fi

sdk_dir="$HOME/Library/Android/sdk"
jdk_dir="$HOME/Library/Java/JavaVirtualMachines/tonasa-temurin-21.jdk"
cache_dir="$HOME/Library/Caches/tonasa-android"

echo 'Pemasangan Java 21 dan Android SDK untuk build APK Tonasa.'
echo 'SDK: https://developer.android.com/studio#command-line-tools-only'
echo 'Lisensi SDK: https://developer.android.com/studio/terms'
echo 'Unduhan termasuk NDK dapat melebihi 1 GB; build APK tidak dijalankan.'
read -r -p 'Sudah membaca dan menyetujui lisensi SDK, lalu lanjut unduh? [y/N] ' jawaban
case "$jawaban" in
  y|Y|yes|YES) ;;
  *) echo 'Pemasangan dibatalkan.'; exit 0 ;;
esac

mkdir -p "$cache_dir"
staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/tonasa-android.XXXXXX")"
trap 'rm -rf "$staging_dir"' EXIT

cek_hash() {
  [[ -f "$1" ]] && [[ "$(shasum -a 256 "$1" | awk '{print $1}')" == "$2" ]]
}
unduh() {
  local url="$1" berkas="$2" checksum="$3"
  if cek_hash "$berkas" "$checksum"; then
    echo "Memakai unduhan yang sudah lengkap: $(basename "$berkas")"
    return
  fi
  # Simpan .part agar unduhan terputus dapat dilanjutkan.
  curl --fail --location --retry 3 --connect-timeout 30 --continue-at - \
    --output "$berkas.part" "$url"
  if ! cek_hash "$berkas.part" "$checksum"; then
    echo "Checksum tidak cocok: $berkas.part. Hentikan pemasangan."
    exit 1
  fi
  mv "$berkas.part" "$berkas"
}

if [[ ! -x "$jdk_dir/Contents/Home/bin/java" ]]; then
  if [[ -e "$jdk_dir" ]]; then
    echo "Folder Java sudah ada tetapi belum lengkap: $jdk_dir"
    echo 'Periksa folder tersebut sebelum menjalankan ulang.'
    exit 1
  fi
  unduh \
    'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_x64_mac_hotspot_21.0.13_9.tar.gz' \
    "$cache_dir/temurin21-mac-x64.tar.gz" \
    '9aa1d1c17ae5467a022679e7e0af5c00797d94ac462ed1a46f4db07a8a34a6dd'
  tar -xzf "$cache_dir/temurin21-mac-x64.tar.gz" -C "$staging_dir"
  mkdir -p "$(dirname "$jdk_dir")"
  mv "$staging_dir/jdk-21.0.13+9" "$jdk_dir"
fi
export JAVA_HOME="$jdk_dir/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

sdkmanager="$sdk_dir/cmdline-tools/latest/bin/sdkmanager"
if [[ ! -x "$sdkmanager" ]]; then
  if [[ -e "$sdk_dir/cmdline-tools/latest" ]]; then
    echo "Folder command-line tools sudah ada tetapi belum lengkap: $sdk_dir/cmdline-tools/latest"
    exit 1
  fi
  unduh \
    'https://dl.google.com/android/repository/commandlinetools-mac_x86_64-15859902_latest.zip' \
    "$cache_dir/android-command-line-tools.zip" \
    'c5a6378ab5cf7e0d5701921405115befff13e9ff7417fb588389338f8bd050f3'
  unzip -q "$cache_dir/android-command-line-tools.zip" -d "$staging_dir/sdk"
  mkdir -p "$sdk_dir/cmdline-tools"
  mv "$staging_dir/sdk/cmdline-tools" "$sdk_dir/cmdline-tools/latest"
fi

# Flutter menyimpan lokasi ini, jadi tidak perlu mengubah .zshrc.
flutter config --jdk-dir "$JAVA_HOME"
flutter config --android-sdk "$sdk_dir"

echo 'Baca setiap lisensi yang ditampilkan. Jawab sesuai persetujuan Anda.'
"$sdkmanager" --sdk_root="$sdk_dir" --licenses
"$sdkmanager" --sdk_root="$sdk_dir" \
  'platform-tools' 'platforms;android-36' 'build-tools;36.0.0' 'ndk;28.2.13676358'

echo 'Java dan Android SDK selesai dipasang.'
echo 'Dari folder aplikasi_supir, jalankan sendiri: flutter build apk --release'
echo 'APK: build/app/outputs/flutter-apk/app-release.apk'
