# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is Apollo Docker - a multi-architecture Docker environment for Apollo Vampire 68080 and AmigaOS cross-compilation development. The project provides a containerized alternative to shell script-based toolchain setups, with support for both x86_64 and ARM64 architectures.

## Common Development Commands

### Building and Testing
```bash
# Build Docker image for current platform
make build

# Build multi-architecture images (requires buildx)
make build-multi

# Test the toolchain
make test

# Clean containers and images
make clean
```

### Development Workflows
```bash
# Start interactive development environment
make run

# Start interactive shell only
make shell

# Start VS Code server (accessible at http://localhost:8080)
make vscode

# Create example project
make example
```

### Docker Compose Operations
```bash
# Start development environment
docker-compose up apollo-dev

# Run one-off build command
docker-compose run --rm apollo-build make -C projects/hello-apollo

# Start VS Code server
docker-compose --profile vscode up apollo-vscode
```

## Architecture

### Key Components
- **Multi-arch Dockerfile**: Supports amd64 and arm64 platforms
- **Cross-compilation toolchain**: GCC 6.5.0 optimized for Apollo Vampire 68080
- **SDK integration**: AmigaOS NDK 3.2 and Apollo-specific headers
- **VS Code integration**: Web-based development environment
- **CI/CD**: GitHub Actions for automated builds and testing

### Directory Structure
```
/opt/apollo/           # Toolchain and SDK root
├── toolchain/         # m68k-amigaos cross-compiler
├── sdk/              # Development SDKs and headers
└── setup-env.sh      # Environment configuration

/workspace/           # Development workspace
└── projects/         # User projects
```

### Build Scripts
- `scripts/build-toolchain.sh`: Builds the GCC cross-compiler
- `scripts/install-sdks.sh`: Installs SDKs and creates templates

## Cross-compilation Details

### Target Platform
- **CPU**: Motorola 68080 (Apollo Vampire)
- **OS**: AmigaOS
- **Toolchain**: m68k-amigaos-gcc 6.5.0

### Compiler Flags
```bash
-m68080                # Target Apollo 68080 CPU
-O2                    # Optimization
-noixemul -mcrt=nix13  # Use newlib runtime
```

### Available Tools
- `m68k-amigaos-gcc` - C/C++ compiler
- `m68k-amigaos-ld` - Linker  
- `m68k-amigaos-as` - Assembler
- `m68k-amigaos-gdb` - Debugger

## VS Code Configuration

The project includes complete VS Code setup in `configs/`:
- IntelliSense configuration for Apollo/AmigaOS headers
- Build and debug tasks
- Remote debugging support for Apollo hardware
- Amiga Assembly syntax highlighting

## CI/CD

GitHub Actions workflow (`.github/workflows/build-and-push.yml`):
- Multi-architecture builds
- Automated testing
- Container registry publishing
- Toolchain verification