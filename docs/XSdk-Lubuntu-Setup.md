# xsdk setup on Lubuntu

## Important host compatibility note

The upstream xsdk Getting Started guide currently documents **Windows 10/11 + WSL 2 + Debian 13**, not native Lubuntu. Its build scripts use ordinary GNU/Linux tools and may work on Lubuntu, but this adaptation is experimental. If a native build fails, keep the complete error and log; don't blindly patch compiler flags.

Official references:
- https://github.com/xenosworks/xsdk
- https://github.com/xenosworks/xsdk/blob/main/docs/GETTING_STARTED.md
- https://github.com/xenosworks/xsdk/blob/main/tools/toolchain/build.sh
- https://github.com/xenosworks/glslang-xenon

## Hardware and storage

- The target must be an RGH/JTAG Xbox 360 able to launch unsigned .xex titles. A retail/unmodified console cannot run these unsigned titles.
- Use a controller to navigate the samples; the upstream template exits when Back is pressed.
- This workflow does not use FTP. Built .xex files can be copied to USB/SSD from Lubuntu, then moved/launched with Aurora as supported by your storage configuration.
- Do not put Microsoft SDK files, console firmware, NAND dumps, keys, or proprietary binaries in this repository.

## Disk and packages

Allow around 10 GB free for the toolchain build and source trees. Upstream reports roughly 1.5 GB installed and about 7 GB of temporary build space for the compiler toolchain, with more space needed for glslang and SDK builds.

Run these commands from a terminal after reviewing the scripts:

    cd ~/Downloads
    git clone https://github.com/geoffdane927/vibed-360-game.git
    cd vibed-360-game
    less scripts/prepare-lubuntu.sh
    bash scripts/prepare-lubuntu.sh
    less scripts/build-xsdk.sh
    bash scripts/build-xsdk.sh

The prerequisite script installs the usual GNU compiler/build dependencies with sudo apt and clones xsdk to $HOME/xsdk. The build script separately builds the PowerPC toolchain, xenosworks' glslang fork, xsdk itself, and the upstream samples. It does not copy the upstream SDK into this game's repository.

## What is being built

- GCC 15 / binutils / newlib for the target triple powerpc-xsdk-elf, built by upstream tools/toolchain/build.sh.
- glslang-xenon, the shader compiler expected by the upstream guide for GLSL/HLSL workflows.
- xsdk's static library, host-side shader compiler, test title, and samples.
- XEX packaging through upstream tools/elf2xex.py.

The upstream toolchain build script checks downloaded compiler source archives against fixed SHA-256 hashes. The glslang source updater fetches its dependency revisions as declared upstream.

## Verify the build

Run:

    $HOME/xsdk-gcc/bin/powerpc-xsdk-elf-gcc --version
    test -f $HOME/xsdk/build/libxsdk.a && echo "xsdk library exists"
    test -f $HOME/xsdk/build/xsdk_test.xex && echo "test XEX exists"
    find $HOME/xsdk/build/samples -name '*.xex' -type f

The commands should list the cross-compiler, library, test title, and sample titles. These checks confirm that files exist; they do not prove the titles run on the console.

## First sample

Start from upstream samples/template. Its CMakeLists.txt calls xsdk_add_xex(title), which links the title and packs a .xex. Build upstream samples first before changing the game. The template starts the GPU/display, clears the screen, and exits with Back. Use samples/hello and samples/triangle as the next references for controller input and drawing.

For a separate CMake game project, upstream's toolchain file is:

    cmake -S game -B build-game -G Ninja \
      -DCMAKE_TOOLCHAIN_FILE=$HOME/xsdk/cmake/xsdk.cmake \
      -DXSDK_TOOLCHAIN=$HOME/xsdk-gcc
    cmake --build build-game

This command only works after the SDK and toolchain are built and the game directory contains a valid CMakeLists.txt and source files. The game target will need xsdk_add_xex(target).

## Copy to the console without FTP

1. Find the resulting .xex in the game's build directory.
2. Copy it to a folder on a USB/SSD using the Lubuntu file manager.
3. Safely eject the drive and connect it to the Xbox 360.
4. Use Aurora's file manager to copy the .xex to a suitable folder on the console, or launch it from the USB storage if Aurora supports that location.
5. Launch it from Aurora and note any error or behavior. Keep the log file next to the .xex when the title produces one.

## Troubleshooting checklist

- Missing compiler or a failed build stage: inspect $HOME/xsdk-gcc-work/logs/ and report the first error, not just the final failure line.
- CMake older than 3.25 or Python older than 3.11: update the host packages before continuing.
- Shader compilation failure: confirm $HOME/xsdk-gcc/bin/glslang exists and record the exact error.
- Link failure: make sure the target is using the xsdk cross-compiler, not host GCC.
- Title starts then freezes/crashes: console behavior is authoritative; preserve the .xex and its log and record the exact dashboard/console setup.
