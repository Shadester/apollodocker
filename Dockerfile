# Multi-architecture Dockerfile for Apollo Vampire 68080 and AmigaOS cross-compilation
# Supports both x86_64 (amd64) and ARM64 architectures

ARG TARGETPLATFORM
ARG BUILDPLATFORM

FROM --platform=$BUILDPLATFORM ubuntu:24.04

# Set non-interactive frontend for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gawk \
    flex \
    bison \
    expect \
    dejagnu \
    texinfo \
    lhasa \
    git \
    subversion \
    make \
    wget \
    curl \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    gettext \
    texinfo \
    ncurses-dev \
    autoconf \
    rsync \
    libreadline-dev \
    python3 \
    python3-pip \
    unzip \
    lzip \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directories
WORKDIR /opt/apollo
RUN mkdir -p /opt/apollo/{toolchain,projects,sdk}

# Set environment variables
ENV APOLLO_ROOT=/opt/apollo
ENV APOLLO_TOOLCHAIN=${APOLLO_ROOT}/toolchain
ENV APOLLO_SDK=${APOLLO_ROOT}/sdk
ENV PATH=${APOLLO_TOOLCHAIN}/bin:${PATH}

# Git environment variables for non-interactive builds
ENV GIT_TERMINAL_PROMPT=0
ENV GIT_ASKPASS=echo

# Configure Git for container builds
RUN git config --system user.email "build@apollodocker.local" && \
    git config --system user.name "Apollo Docker Build" && \
    git config --system advice.detachedHead false && \
    git config --system url."https://github.com/".insteadOf git@github.com: && \
    git config --system url."https://".insteadOf git:// && \
    git config --system credential.helper ""

# Copy build scripts
COPY scripts/ /opt/apollo/scripts/
RUN chmod +x /opt/apollo/scripts/*.sh

# Build the toolchain
RUN /opt/apollo/scripts/build-toolchain.sh

# Install additional SDKs and libraries
RUN /opt/apollo/scripts/install-sdks.sh

# Create development user
RUN useradd -m -s /bin/bash apollo && \
    usermod -aG sudo apollo && \
    chown -R apollo:apollo /opt/apollo

# Set up workspace for development
WORKDIR /workspace
RUN chown apollo:apollo /workspace

# Switch to development user
USER apollo

# Set up shell environment
RUN echo 'export PATH=/opt/apollo/toolchain/bin:$PATH' >> ~/.bashrc && \
    echo 'export APOLLO_ROOT=/opt/apollo' >> ~/.bashrc && \
    echo 'export APOLLO_TOOLCHAIN=/opt/apollo/toolchain' >> ~/.bashrc && \
    echo 'export APOLLO_SDK=/opt/apollo/sdk' >> ~/.bashrc

# Default command
CMD ["/bin/bash"]

# Labels
LABEL maintainer="Apollo Docker Development Environment"
LABEL description="Cross-compilation environment for Apollo Vampire 68080 and AmigaOS"
LABEL version="1.0"
LABEL architecture="multi-arch (amd64/arm64)"