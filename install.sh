#!/bin/bash
# Build and install the FaceTime HD camera firmware and driver.
# see https://github.com/patjak/facetimehd/wiki/Installation
#
# The driver is installed with DKMS, so it is rebuilt automatically for
# every new kernel. Set FW_VER=1.43.0 to keep the older firmware.
# Pass --force to reinstall the driver even if DKMS reports it as installed.
set -euo pipefail

force=()
for arg in "$@"; do
	case "$arg" in
	--force) force=(--force) ;;
	*) echo "Usage: $0 [--force]" >&2; exit 2 ;;
	esac
done

cd "$(dirname "$(readlink -f "$0")")"

echo "== Updating sources"
git submodule update --init --remote --merge

echo "== Firmware"
cd facetimehd-firmware
make clean >/dev/null
make ${FW_VER:+FW_VER=$FW_VER}
sudo make install

echo "== Driver ($(git -C ../bcwc_pcie branch --show-current))"
cd ../bcwc_pcie
ver=$(sed -n 's/^PACKAGE_VERSION=//p' dkms.conf)
src=/usr/src/facetimehd-$ver

# Replace any previous DKMS copy of this version with the current sources
if dkms status "facetimehd/$ver" | grep -q .; then
	sudo dkms remove "facetimehd/$ver" --all
fi
sudo rm -rf "$src"
sudo mkdir -p "$src"
git ls-files -z | sudo xargs -0 cp --parents -t "$src"
sudo dkms install "facetimehd/$ver" ${force[@]+"${force[@]}"}

# Copies from a plain "make install" would shadow the DKMS module
sudo rm -f /lib/modules/*/updates/facetimehd.ko
sudo depmod

echo "== Loading the new driver"
if ! sudo modprobe -r facetimehd; then
	echo "The camera is in use; close all camera apps and run: sudo modprobe -r facetimehd && sudo modprobe facetimehd" >&2
	exit 1
fi
sudo modprobe facetimehd

echo "Driver installed: facetimehd $ver, srcversion $(cat /sys/module/facetimehd/srcversion)"
