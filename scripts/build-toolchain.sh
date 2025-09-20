#!/bin/bash
set -e

# Apollo Vampire 68080 and AmigaOS Cross-Compilation Toolchain Builder
# Based on WDrijver/ApolloCrossDev but adapted for Docker multi-arch

echo "Building Apollo Vampire 68080 Cross-Compilation Toolchain..."
echo "Platform: $(uname -m)"
echo "Target: m68k-amigaos"

# Configuration
APOLLO_ROOT=/opt/apollo
TOOLCHAIN_PREFIX=${APOLLO_ROOT}/toolchain
WORKSPACE=${APOLLO_ROOT}/build
PARALLEL_JOBS=$(nproc)

# Create directories
mkdir -p ${WORKSPACE}
mkdir -p ${TOOLCHAIN_PREFIX}

cd ${WORKSPACE}

echo "Cleaning workspace..."
rm -rf amiga-gcc || true

echo "Cloning Amiga-GCC repository..."
git clone https://github.com/WDrijver/amiga-gcc.git
cd amiga-gcc

echo "Building GCC 6.5.0 for m68k-amigaos..."
echo "Using ${PARALLEL_JOBS} parallel jobs"

# Build and install the complete toolchain
echo "Building and installing minimal toolchain..."
make -j${PARALLEL_JOBS} min \
    PREFIX=${TOOLCHAIN_PREFIX}

# Verify installation
if [ -f "${TOOLCHAIN_PREFIX}/bin/m68k-amigaos-gcc" ]; then
    echo "✓ GCC cross-compiler installed successfully"
    ${TOOLCHAIN_PREFIX}/bin/m68k-amigaos-gcc --version
else
    echo "✗ GCC cross-compiler installation failed"
    exit 1
fi

if [ -f "${TOOLCHAIN_PREFIX}/bin/m68k-amigaos-ld" ]; then
    echo "✓ Binutils installed successfully"
else
    echo "✗ Binutils installation failed"
    exit 1
fi

echo "Toolchain build completed successfully!"
echo "Installation directory: ${TOOLCHAIN_PREFIX}"
echo "Add ${TOOLCHAIN_PREFIX}/bin to your PATH to use the tools"