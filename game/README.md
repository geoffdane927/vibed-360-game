# Game source

This directory is reserved for the actual game title. First get the upstream xsdk test and samples building; then add a CMake project here based on $HOME/xsdk/samples/template.

A minimal title project needs a CMakeLists.txt, source code, and xsdk_add_xex(target). Do not copy the full SDK or its generated toolchain into this repository.
