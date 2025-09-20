#!/bin/bash
set -e

# Install SDKs and Development Kits for Apollo/AmigaOS development

echo "Installing Apollo/AmigaOS SDKs and Development Kits..."

APOLLO_ROOT=/opt/apollo
SDK_ROOT=${APOLLO_ROOT}/sdk
WORKSPACE=${APOLLO_ROOT}/build

mkdir -p ${SDK_ROOT}/{ndk,mui5,sdl,freetype,opengl}
cd ${WORKSPACE}

# Install NDK (Native Development Kit)
echo "Installing Amiga NDK 3.2..."
cd ${WORKSPACE}
wget -q http://aminet.net/dev/misc/NDK3.2.lha -O NDK3.2.lha
if command -v lhasa >/dev/null 2>&1; then
    lhasa -xf NDK3.2.lha
elif command -v lha >/dev/null 2>&1; then
    lha -xf NDK3.2.lha
else
    echo "Warning: No LHA extractor found, skipping NDK installation"
fi

if [ -d "NDK_3.2" ]; then
    cp -r NDK_3.2/* ${SDK_ROOT}/ndk/
    echo "✓ NDK 3.2 installed"
else
    echo "⚠ NDK 3.2 installation skipped"
fi

# Install additional development headers
echo "Installing additional development headers..."
cat > ${SDK_ROOT}/apollo_extensions.h << 'EOF'
#ifndef APOLLO_EXTENSIONS_H
#define APOLLO_EXTENSIONS_H

/* Apollo Vampire 68080 specific extensions */
#include <exec/types.h>

/* Apollo specific CPU features */
#define APOLLO_68080_CPU 1

/* Vampire specific memory management */
void* apollo_alloc_fast(ULONG size);
void apollo_free_fast(void* ptr);

/* Serial debugging support */
void apollo_debug_printf(const char* format, ...);

#endif /* APOLLO_EXTENSIONS_H */
EOF

# Create basic Apollo library structure
echo "Setting up Apollo library structure..."
mkdir -p ${SDK_ROOT}/apollo/{include,lib}
cp ${SDK_ROOT}/apollo_extensions.h ${SDK_ROOT}/apollo/include/

# Create a basic makefile template
cat > ${SDK_ROOT}/Makefile.template << 'EOF'
# Apollo Vampire 68080 Cross-Compilation Makefile Template

# Toolchain configuration
CC = m68k-amigaos-gcc
LD = m68k-amigaos-ld
AS = m68k-amigaos-as
OBJCOPY = m68k-amigaos-objcopy

# Apollo-specific compiler flags
CFLAGS = -m68080 -O2 -fomit-frame-pointer -Wall
CFLAGS += -noixemul -mcrt=nix13
CFLAGS += -I$(APOLLO_SDK)/ndk/include
CFLAGS += -I$(APOLLO_SDK)/apollo/include

# Linker flags
LDFLAGS = -noixemul -mcrt=nix13
LDFLAGS += -L$(APOLLO_SDK)/ndk/lib

# Source and target
SOURCES = main.c
TARGET = program

# Build rules
$(TARGET): $(SOURCES)
	$(CC) $(CFLAGS) $(SOURCES) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET) *.o

.PHONY: clean
EOF

echo "Creating build environment script..."
cat > ${APOLLO_ROOT}/setup-env.sh << 'EOF'
#!/bin/bash
# Apollo development environment setup

export APOLLO_ROOT=/opt/apollo
export APOLLO_TOOLCHAIN=${APOLLO_ROOT}/toolchain
export APOLLO_SDK=${APOLLO_ROOT}/sdk
export PATH=${APOLLO_TOOLCHAIN}/bin:${PATH}

echo "Apollo Vampire 68080 Development Environment"
echo "Toolchain: ${APOLLO_TOOLCHAIN}"
echo "SDK: ${APOLLO_SDK}"
echo "Available tools:"
which m68k-amigaos-gcc 2>/dev/null && echo "  ✓ GCC cross-compiler"
which m68k-amigaos-ld 2>/dev/null && echo "  ✓ Linker"
which m68k-amigaos-as 2>/dev/null && echo "  ✓ Assembler"
EOF

chmod +x ${APOLLO_ROOT}/setup-env.sh

echo "✓ SDK installation completed"
echo "Use 'source /opt/apollo/setup-env.sh' to set up your environment"