FROM ubuntu

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
    bash \
    bash-completion \
    build-essential \
    curl \
    wget \
    ca-certificates \
    htop \
    locales \
    man \
    python3 \
    python3-pip \
    software-properties-common \
    sudo \
    fontconfig && \
    # Install latest Git using their official PPA
    add-apt-repository ppa:git-core/ppa && \
    DEBIAN_FRONTEND="noninteractive" apt-get install --yes git

# Add a user `coder` so that you're not developing as the `root` user
ARG USER=coder

RUN useradd ${USER} \
    --groups sudo \
    --create-home \
    --shell=/bin/bash \
    --uid=1000 \
    --user-group \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}

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

USER 0:0
RUN curl -sSL -o /tmp/racket.sh https://download.racket-lang.org/installers/8.9/racket-8.9-x86_64-linux-cs.sh && \
  sh /tmp/racket.sh --unix-style --create-dir --dest /usr && \
  rm /tmp/racket.sh

USER ${USER}
SHELL ["/bin/bash", "--login", "-c"]
