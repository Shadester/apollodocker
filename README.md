# Apollo Docker Cross-Development Environment

A comprehensive Docker-based cross-compilation environment for Apollo Vampire 68080 and AmigaOS development. This project provides a proper containerized alternative to shell script-based setups, with full multi-architecture support (amd64/arm64).

## Features

- **Multi-Architecture Support**: Native builds for both x86_64 and ARM64 systems
- **Complete Toolchain**: GCC 6.5.0 optimized for Apollo Vampire 68080
- **Integrated Development**: VS Code server support for web-based development
- **Ready-to-Use SDKs**: AmigaOS NDK 3.2 and Apollo-specific extensions
- **CI/CD Ready**: GitHub Actions workflows for automated building and testing
- **Docker Compose**: Simplified development workflows

## Quick Start

### Prerequisites

- Docker 20.10+ with BuildKit support
- Docker Compose 2.0+
- For multi-arch builds: Docker Buildx

### Basic Usage

1. **Clone and build:**
   ```bash
   git clone https://github.com/Shadester/apollodocker.git
   cd apollodocker
   make build
   ```

2. **Start development environment:**
   ```bash
   make run
   ```

3. **Test the toolchain:**
   ```bash
   make test
   ```

### Development Workflows

#### Interactive Development
```bash
# Start interactive shell
make shell

# Inside container:
source /opt/apollo/setup-env.sh
cd /workspace/projects/hello-apollo
make
```

#### VS Code Server
```bash
# Start VS Code server (accessible at http://localhost:8080)
make vscode
```

#### Quick Compilation
```bash
# Using Docker Compose for one-off builds
docker-compose run --rm apollo-build make -C projects/hello-apollo
```

## Architecture

### Toolchain Components

- **GCC 6.5.0**: Apollo-optimized cross-compiler (m68k-amigaos)
- **Binutils**: Complete assembler, linker, and utilities
- **Apollo Extensions**: Custom headers and library stubs
- **AmigaOS NDK 3.2**: Native Development Kit

### Container Structure

```
/opt/apollo/
├── toolchain/          # Cross-compilation toolchain
│   └── bin/            # m68k-amigaos-* tools
├── sdk/                # Development SDKs
│   ├── ndk/           # AmigaOS NDK 3.2
│   └── apollo/        # Apollo-specific headers
└── setup-env.sh       # Environment setup script

/workspace/             # Development workspace
└── projects/          # Your projects
```

### Multi-Architecture Support

The Docker images are built for both platforms:
- `linux/amd64` - Intel/AMD x86_64 systems
- `linux/arm64` - ARM64 systems (Apple Silicon, etc.)

## Project Structure

```
apollodocker/
├── Dockerfile              # Main development image
├── Dockerfile.vscode       # VS Code server image
├── docker-compose.yml      # Compose configuration
├── Makefile                # Build automation
├── scripts/                # Build and setup scripts
│   ├── build-toolchain.sh
│   └── install-sdks.sh
├── configs/                # VS Code configurations
│   ├── vscode-settings.json
│   ├── vscode-tasks.json
│   └── vscode-launch.json
├── projects/               # Example projects
│   └── hello-apollo/
└── .github/workflows/      # CI/CD pipelines
```

## Available Make Targets

| Target | Description |
|--------|-------------|
| `help` | Show available targets |
| `build` | Build Docker image for current platform |
| `build-multi` | Build multi-architecture images |
| `run` | Run development container |
| `shell` | Start interactive shell |
| `vscode` | Start VS Code server |
| `test` | Verify toolchain installation |
| `clean` | Clean containers and images |
| `example` | Create example project |

## Development Guide

### Creating a New Project

1. **Create project directory:**
   ```bash
   mkdir projects/my-project
   cd projects/my-project
   ```

2. **Copy Makefile template:**
   ```bash
   cp /opt/apollo/sdk/Makefile.template ./Makefile
   ```

3. **Write your code:**
   ```c
   #include <stdio.h>
   #include <exec/types.h>
   
   int main() {
       printf("Hello Apollo!\n");
       return 0;
   }
   ```

4. **Compile:**
   ```bash
   make
   ```

### Compiler Flags

The toolchain includes Apollo-optimized flags:

```bash
-m68080                 # Target Apollo 68080 CPU
-O2                     # Optimization level 2
-fomit-frame-pointer    # Omit frame pointer for speed
-noixemul               # Use newlib instead of ixemul
-mcrt=nix13             # Use nix13 C runtime
```

### Available Tools

All standard GNU cross-compilation tools are available:

- `m68k-amigaos-gcc` - C/C++ compiler
- `m68k-amigaos-ld` - Linker
- `m68k-amigaos-as` - Assembler
- `m68k-amigaos-ar` - Archiver
- `m68k-amigaos-objcopy` - Object copy utility
- `m68k-amigaos-objdump` - Object dump utility
- `m68k-amigaos-gdb` - Debugger

## VS Code Integration

The project includes full VS Code configuration for Apollo development:

### Features
- Syntax highlighting for C/C++ and assembly
- IntelliSense with Apollo/AmigaOS headers
- Build tasks for compilation
- Debug configurations (local and remote)
- Integrated terminal with toolchain in PATH

### Extensions
- Microsoft C/C++ Extension Pack
- Amiga Assembly (if available)

## CI/CD Integration

GitHub Actions workflows provide:
- Automatic multi-arch builds on push/PR
- Toolchain verification tests
- Container registry publishing
- Automated testing with sample compilation

## Volumes and Persistence

Docker volumes preserve toolchain and SDK data:
- `apollo-toolchain` - Compiled toolchain binaries
- `apollo-sdk` - SDK and development headers

Mount your projects directory for persistent development:
```bash
docker run -v $(pwd)/projects:/workspace/projects apollo-crossdev:latest
```

## Troubleshooting

### Build Issues

1. **Out of memory during build:**
   ```bash
   # Reduce parallel jobs
   docker build --build-arg PARALLEL_JOBS=2 .
   ```

2. **Permission issues:**
   ```bash
   # Fix container permissions
   sudo chown -R $USER:$USER projects/
   ```

### Toolchain Issues

1. **Missing tools:**
   ```bash
   # Verify installation
   docker run --rm apollo-crossdev:latest m68k-amigaos-gcc --version
   ```

2. **Compilation errors:**
   ```bash
   # Check environment
   source /opt/apollo/setup-env.sh
   echo $PATH
   ```

## Contributing

1. Fork the repository
2. Create feature branch
3. Test changes with `make test`
4. Submit pull request

## License

This project builds upon the work of the [ApolloCrossDev](https://github.com/WDrijver/ApolloCrossDev) project and respects all upstream licenses.

## Resources

- [Apollo Vampire 68080 Documentation](http://www.apollo-core.com/)
- [Original ApolloCrossDev Project](https://github.com/WDrijver/ApolloCrossDev)
- [AmigaOS Developer Documentation](http://amigadev.elowar.com/)
- [GCC Cross-Compilation Guide](https://gcc.gnu.org/install/configure.html)