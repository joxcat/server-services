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
    fontconfig \
    wget && \
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
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd && \
    chsh -s /bin/bash ${USER}

# As the user
ENV HOME /home/${USER}
USER ${USER}
WORKDIR /home/${USER}
SHELL ["/bin/bash", "--login", "-c"]

# Setup git
RUN git config --global init.defaultBranch main

# Add custom fonts
RUN mkdir $HOME/.fonts || true
RUN cd $HOME/.fonts && \
    curl -sSL -o iosevka.tar.gz https://github.com/joxcat/Iosevka-custom-conf/releases/download/v1.2.0/iosevka.tar.gz && \
    tar -xf iosevka.tar.gz && \
    rm iosevka.tar.gz && \
    fc-cache -f

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3
RUN echo '. "$HOME/.asdf/asdf.sh"' >> "$HOME/.bashrc" \
    && echo '. "$HOME/.asdf/completions/asdf.bash"' >> "$HOME/.bashrc"

