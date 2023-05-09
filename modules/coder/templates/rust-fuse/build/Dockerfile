FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
    bash \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    htop \
    locales \
    man \
    python3 \
    python3-pip \
    software-properties-common \
    sudo \
    systemd \
    systemd-sysv \
    unzip \
    wget \
    libfuse3-dev \
    fuse3 && \
    # Install latest Git using their official PPA
    add-apt-repository ppa:git-core/ppa && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes git

# Add a user `coder` so that you're not developing as the `root` user
ARG USER=coder

RUN useradd ${USER} \
    --create-home \
    --shell=/bin/bash \
    --uid=1000 \
    --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER ${USER}
WORKDIR /home/${USER}

# Setup git
RUN git config --global init.defaultBranch main

# set env variables

# setup rust
USER 0:0
RUN apt-get install -y --no-install-recommends \
    lld \
    binaryen \
    clang \
    pkg-config \
    libstdc++-10-dev \
    cmake \
    libssl-dev
RUN git clone https://github.com/rui314/mold.git --depth 1 --branch v1.10.1 /home/${USER}/mold && \
    mkdir /home/${USER}/mold/build && \
    cd /home/${USER}/mold/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=/usr/bin/clang++ .. && \
    cmake --build . -j $(nproc) && \
    cmake --install . && \
    cd / && \
    rm -rf /home/${USER}/mold
USER ${USER}
SHELL ["/bin/bash", "--login", "-c"]
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=$PATH:$HOME/.cargo/bin
# Rust-analyser
RUN rustup component add clippy rustfmt rust-analyzer
RUN rustup +nightly component add clippy rustfmt rust-analyzer
RUN mkdir -p $HOME/.cargo/bin && \
    ln -s $(rustup which --toolchain stable rust-analyzer) $HOME/.cargo/bin/rust-analyzer-stable && \
    ln -s $(rustup which --toolchain nightly rust-analyzer) $HOME/.cargo/bin/rust-analyzer-nightly && \
    chown ${USER} $HOME/.cargo/bin/rust-analyzer-stable $HOME/.cargo/bin/rust-analyzer-nightly
# # Targets
# RUN rustup target add wasm32-unknown-unknown
# RUN rustup target add x86_64-unknown-linux-musl
# # Kani tests
# RUN cargo install --locked kani-verifier && \
#     cargo-kani setup
# # Add Cranelift compiler
# RUN mkdir $HOME/.apps
# RUN git clone https://github.com/bjorn3/rustc_codegen_cranelift.git $HOME/rustc_codegen_cranelift --depth 1 && \
#     cd $HOME/rustc_codegen_cranelift && \
#     ./y.rs prepare && \
#     ./y.rs build && \
#     mv dist/cargo-clif "$HOME/.apps"
# RUN ln -s $HOME/.apps/cargo-clif $HOME/.cargo/bin/cargo-clif && \
#     rm -rf $HOME/rustc_codegen_cranelift
RUN cargo install --locked cargo-bloat cargo-expand cargo-watch cargo-nextest sea-orm-cli
