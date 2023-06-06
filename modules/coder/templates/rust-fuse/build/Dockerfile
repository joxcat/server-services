FROM ubuntu

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
    bash \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    wget \
    htop \
    locales \
    man \
    python3 \
    python3-pip \
    software-properties-common \
    sudo \
    fontconfig \
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

# Add custom fonts
RUN mkdir $HOME/.fonts || true
RUN cd $HOME/.fonts && \
    curl -sSL -o iosevka.tar.gz https://github.com/joxcat/Iosevka-custom-conf/releases/download/v1.2.0/iosevka.tar.gz && \
    tar -xf iosevka.tar.gz && \
    rm iosevka.tar.gz && \
    fc-cache -f

# set env variables

# setup rust
USER 0:0
RUN apt-get install -y --no-install-recommends \
    lld \
    clang \
    pkg-config \
    libstdc++-10-dev \
    cmake \
    libssl-dev
RUN git clone https://github.com/rui314/mold.git --depth 1 --branch v1.11.0 /home/${USER}/mold && \
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
RUN cargo install --locked cargo-bloat cargo-expand
