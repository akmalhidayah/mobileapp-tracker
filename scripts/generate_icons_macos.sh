#!/usr/bin/env bash
# Mengubah ukuran aset pengguna secara deterministik; tidak menjalankan build.
set -euo pipefail
project_dir="$(cd "$(dirname "$0")/.." && pwd)"
icon_source="$project_dir/assets/branding/app_icon.png"
res_dir="$project_dir/android/app/src/main/res"
web_dir="$project_dir/web"

resize_icon() {
  local size="$1" output="$2"
  mkdir -p "$(dirname "$output")"
  sips -z "$size" "$size" "$icon_source" --out "$output" >/dev/null
}

pad_icon() {
  local content_size="$1" canvas_size="$2" output="$3"
  resize_icon "$content_size" "$output"
  sips --padToHeightWidth "$canvas_size" "$canvas_size" \
    --padColor FFFFFF "$output" >/dev/null
}

for spec in mdpi:48:108:72 hdpi:72:162:108 xhdpi:96:216:144 xxhdpi:144:324:216 xxxhdpi:192:432:288; do
  IFS=: read -r density legacy_size layer_size content_size <<< "$spec"
  resize_icon "$legacy_size" "$res_dir/mipmap-$density/ic_launcher.png"
  pad_icon "$content_size" "$layer_size" "$res_dir/mipmap-$density/ic_launcher_foreground.png"
done

resize_icon 32 "$web_dir/favicon.png"
resize_icon 180 "$web_dir/icons/apple-touch-icon.png"
for size in 192 512; do
  resize_icon "$size" "$web_dir/icons/Icon-$size.png"
  pad_icon "$((size * 4 / 5))" "$size" "$web_dir/icons/Icon-maskable-$size.png"
done
echo 'Ikon Android, favicon, Apple touch icon, dan ikon web selesai dibuat.'
