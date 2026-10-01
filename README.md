# macbook-camera

Installs the Linux driver and firmware for the FaceTime HD camera (Broadcom 1570, PCI ID `14e4:1570`). That camera is in most Intel Macs from about 2013 to 2017: MacBook Air, MacBook Pro, the 12-inch MacBook and some iMacs.

To check whether your Mac has it:

```bash
lspci -nn | grep 14e4:1570
```

## Install

```bash
git clone --recurse-submodules https://github.com/pschatzmann/macbook-camera.git
cd macbook-camera
./install.sh
```

`install.sh` does the following:

1. Updates both submodules.
2. Builds the firmware from Apple's macOS update and installs it.
3. Installs the driver with DKMS, so it's rebuilt automatically for every new kernel.
4. Reloads the driver.

Close any app that uses the camera before running it. To keep the older 1.43.0 firmware, run `FW_VER=1.43.0 ./install.sh`.

## Contents

- **`bcwc_pcie`**: the driver. It points to the `fix-buffer-handling` branch of [pschatzmann/facetimehd](https://github.com/pschatzmann/facetimehd), which carries the fixes from [patjak/facetimehd#355](https://github.com/patjak/facetimehd/pull/355). Without them, apps that use the camera through PipeWire (browsers, video calls) fail or freeze. Once that PR is merged, the submodule can point to [patjak/facetimehd](https://github.com/patjak/facetimehd) again.
- **`facetimehd-firmware`**: [patjak/facetimehd-firmware](https://github.com/patjak/facetimehd-firmware), which extracts the firmware and sensor calibration files.
