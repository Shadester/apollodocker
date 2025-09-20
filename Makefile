# Apollo Docker Development Environment Makefile

.PHONY: build build-multi run shell clean test help

# Default target
help:
	@echo "Apollo Vampire 68080 Docker Development Environment"
	@echo ""
	@echo "Available targets:"
	@echo "  build       - Build Docker image for current platform"
	@echo "  build-multi - Build multi-architecture images (amd64/arm64)"
	@echo "  run         - Run development container"
	@echo "  shell       - Start interactive shell in container"
	@echo "  vscode      - Start VS Code server container"
	@echo "  test        - Run tests to verify toolchain"
	@echo "  clean       - Clean up containers and images"
	@echo "  push        - Push images to registry"

# Build for current platform
build:
	docker build -t apollo-crossdev:latest .

# Build multi-architecture images
build-multi:
	docker buildx create --name apollo-builder --use || true
	docker buildx build --platform linux/amd64,linux/arm64 -t apollo-crossdev:latest .

# Build VS Code image
build-vscode: build
	docker build -f Dockerfile.vscode -t apollo-crossdev-vscode:latest .

# Run development container
run:
	docker-compose up apollo-dev

# Start interactive shell
shell:
	docker-compose run --rm apollo-dev /bin/bash

# Start VS Code server
vscode: build-vscode
	docker-compose --profile vscode up apollo-vscode

# Test the toolchain
test:
	@echo "Testing Apollo toolchain..."
	docker run --rm apollo-crossdev:latest bash -c " \
		source /opt/apollo/setup-env.sh && \
		echo 'Testing GCC...' && \
		m68k-amigaos-gcc --version && \
		echo 'Testing linker...' && \
		m68k-amigaos-ld --version && \
		echo 'Testing compilation...' && \
		echo '#include <stdio.h>' > test.c && \
		echo 'int main() { printf(\"Hello Apollo!\"); return 0; }' >> test.c && \
		m68k-amigaos-gcc -m68080 -O2 -noixemul test.c -o test && \
		echo 'All tests passed!'"

# Clean up
clean:
	docker-compose down -v
	docker system prune -f
	docker volume prune -f

# Push to registry (requires login)
push: build-multi
	docker push apollo-crossdev:latest

# Create example project structure
example:
	mkdir -p projects/hello-apollo
	cp /dev/null projects/hello-apollo/main.c || echo '#include <stdio.h>\n\nint main() {\n    printf("Hello Apollo Vampire 68080!\\n");\n    return 0;\n}' > projects/hello-apollo/main.c
	cp scripts/../configs/../* projects/hello-apollo/ 2>/dev/null || true
	@echo "Example project created in projects/hello-apollo/"

# Development setup
setup: build example
	@echo "Apollo development environment setup complete!"
	@echo "Run 'make run' to start developing"