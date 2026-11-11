#!/bin/bash
# Run only inside the disposable privileged Debian 13 build container.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
[[ -f /.dockerenv && $(id -u) == 0 ]] || { echo 'Use the GitHub Actions build container.' >&2; exit 1; }
[[ $(dpkg --print-architecture) == amd64 ]] || { echo 'This workflow builds amd64 only.' >&2; exit 1; }
cd /src
[[ -f package.json && -d server ]] || exit 1

apt-get update
apt-get install -y --no-install-recommends \
  build-essential pkg-config git curl ca-certificates gnupg unzip \
  nodejs npm python3 cmake clang \
  debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin \
  grub-common mtools dosfstools file \
  libxkbcommon-dev libwayland-dev wayland-protocols libcrypt-dev \
  libgbm-dev libegl-dev libgles-dev libssl-dev \
  libpoppler-glib-dev libarchive-dev libcairo2-dev libfreetype-dev libfontconfig-dev \
  libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev \
  libva-dev libsrtp2-dev libusrsctp-dev freerdp3-dev \
  libtesseract-dev libpipewire-0.3-dev libsystemd-dev \
  glslc libvulkan-dev spirv-headers

# Extraction on Windows may not retain executable bits. Normalize only build scripts.
find tools -type f -name '*.sh' -exec chmod +x {} +
npm ci --no-audit --no-fund
npm run build:brand
npm run build
node tools/code-manifest.mjs --check
sh tools/tts/fetch-audiocpp.sh
make -C server -j"$(nproc)"
make -C server test

mkdir -p /var/tmp/phos-iso/out /src/iso-output
sh tools/iso/mkdeb-rclone.sh /var/tmp/phos-iso/out amd64
sh tools/iso/build.sh /var/tmp/phos-iso

shopt -s nullglob
images=(/var/tmp/phos-iso/out/phos-live-*-amd64.iso)
[[ ${#images[@]} == 1 ]] || { echo 'Expected exactly one PHOS ISO.' >&2; exit 1; }
cp "${images[0]}" /src/iso-output/
cd /src/iso-output
sha256sum phos-live-*-amd64.iso > SHA256SUMS
echo 'PHOS ISO built. This is an unsigned development image, not a tested release.'
