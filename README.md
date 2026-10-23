# vibed-360-game — Xbox 360 xsdk starter

This repository is being prepared for native Xbox 360 homebrew using [xenosworks/xsdk](https://github.com/xenosworks/xsdk).

**Target:** an RGH/JTAG Xbox 360 S that can launch unsigned .xex titles.  
**Development host:** Lubuntu/Linux. The upstream xsdk guide currently documents Windows 10/11 + WSL 2 + Debian; native Lubuntu is a best-effort adaptation and is not yet verified by this repository.

## What is included here

- docs/XSdk-Lubuntu-Setup.md — prerequisites and reproducible setup steps.
- scripts/prepare-lubuntu.sh — installs Ubuntu/Debian build prerequisites after confirmation and clones xsdk.
- scripts/build-xsdk.sh — builds the xsdk PowerPC toolchain, its matching shader compiler, the SDK, and sample titles.
- game/ — the game's source will live here, separately from the SDK.

We do **not** copy the SDK source or compiled toolchain into this game repository. The scripts clone the upstream SDK from its official repository, so its license, source history, and updates remain clear.

## Quick start (Lubuntu)

Review the script before running it. It uses sudo apt to install packages and creates $HOME/xsdk, $HOME/xsdk-gcc, and $HOME/xsdk-gcc-work.

    git clone https://github.com/geoffdane927/vibed-360-game.git
    cd vibed-360-game
    less scripts/prepare-lubuntu.sh
    bash scripts/prepare-lubuntu.sh
    less scripts/build-xsdk.sh
    bash scripts/build-xsdk.sh

The SDK build downloads source archives from upstream and checks the toolchain source archives against SHA-256 hashes. The build can require roughly 10 GB free space during compilation.

## First build output

A successful build should produce:

- $HOME/xsdk-gcc/bin/powerpc-xsdk-elf-gcc
- $HOME/xsdk/build/libxsdk.a
- $HOME/xsdk/build/xsdk_test.xex
- sample .xex files below $HOME/xsdk/build/samples/

A successful compile is not proof that a title works on your console. Upstream xsdk recommends testing on an RGH/JTAG console; Xenia can be used for limited smoke checks but is not a substitute for hardware.

## Console transfer

This project deliberately does not require FTP. After building a game's .xex, copy it to a USB/SSD using the file manager, connect the drive to the Xbox 360, and use Aurora's file manager to copy it to a folder on the console or launch it from the supported storage location. Exact behavior depends on how your drive is formatted and configured.

## Upstream references

- [xsdk source and overview](https://github.com/xenosworks/xsdk)
- [xsdk Getting Started guide](https://github.com/xenosworks/xsdk/blob/main/docs/GETTING_STARTED.md)
- [xsdk template sample](https://github.com/xenosworks/xsdk/tree/main/samples/template)

## Status

No .xex has been built or tested on hardware by this repository yet. Follow the setup guide, keep the first milestone small, and save build logs if anything fails.
