FROM ubuntu

ARG LC_ALL=C
ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  apt-transport-https \
  bash \
  ca-certificates \
  curl \
  git \
  sudo \
  vim \
  wget \
  locales \
  make \
  cmake \
  build-essential \
  pkg-config \
  libssl-dev \
  zlib1g-dev \
  gcc \
  g++ \
  llvm \
  file \
  musl-dev\
  musl-tools \
  linux-tools-common \
  linux-tools-generic \
  strace \
  clang \
  lld \
  binaryen \
  sqlite3 \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*

# Build and install mold linker
RUN cd /tmp && \
    git clone https://github.com/rui314/mold.git --depth 1 --branch v1.9.0
RUN cd /tmp/mold && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++ .. && \
    cmake --build . -j $(nproc)
RUN cd /tmp/mold/build && \
    cmake --install . && \
    cd / && \
    rm -rf /tmp/mold

ARG USER=coder
RUN useradd --groups sudo --shell=/bin/bash --create-home ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}
USER ${USER}
WORKDIR /home/${USER}
ENV HOME=/home/${USER}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=$PATH:${HOME}/.cargo/bin

RUN rustup component add clippy rustfmt rust-analyzer
RUN rustup +nightly component add clippy rustfmt rust-analyzer

# Targets
RUN rustup target add wasm32-unknown-unknown
RUN rustup target add x86_64-unknown-linux-musl

# Kani tests
RUN cargo install --locked kani-verifier && \
    cargo-kani setup

# Add Cranelift compiler
ARG GIT_EMAIL="coder@example.org"
RUN git config --global user.email ${GIT_EMAIL}
ARG GIT_NAME="coder"
RUN git config --global user.name ${GIT_NAME}
RUN git clone https://github.com/bjorn3/rustc_codegen_cranelift.git /tmp/rustc_codegen_cranelift --depth 1 && \
    cd /tmp/rustc_codegen_cranelift && \
    ./y.rs prepare && \
    ./y.rs build
RUN cp /tmp/rustc_codegen_cranelift/dist/cargo-clif "$HOME/.cargo/bin"

RUN cargo install --locked cargo-bloat cargo-expand cargo-watch cargo-nextest sea-orm-cli

USER 0
RUN rm -rf /tmp/*
USER ${USER}
