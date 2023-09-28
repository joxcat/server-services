ARG ALPINE_IMAGE=alpine:edge

FROM ${ALPINE_IMAGE} as build

WORKDIR /root/rtorrent

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

RUN apk --no-cache add bash git

# Checkout rTorrent sources from Github repository
RUN git clone https://github.com/rakshasa/rtorrent.git . \
    && git reset --hard 1da0e3476dcabbf74b2e836d6b4c37b4d96bde09

# Install build dependencies
RUN apk --no-cache add \
    build-base \
    coreutils \
    linux-headers \
    automake \
    autoconf-archive \
    ncurses-dev \
    libtool \
    curl-dev \
    pkgconfig

WORKDIR /root/libtorrent
RUN git clone https://github.com/rakshasa/libtorrent.git . \
    && git reset --hard 91f8cf4b0358d9b4480079ca7798fa7d9aec76b5

RUN autoreconf -vfi
RUN ls && ./configure --prefix=/usr \
    && make \
    && make install

WORKDIR /root/rtorrent
RUN autoreconf -vfi
RUN ./configure \
    && make

# Now get the clean image
FROM ${ALPINE_IMAGE} as build-sysroot

# Fetch runtime dependencies
RUN apk --no-cache add \
  libcurl \
  libgcc \
  libncursesw \
  libstdc++

COPY --from=build /root/rtorrent/src/rtorrent /usr/bin/rtorrent
COPY --from=build \
    /usr/lib/libtorrent.so \
    /usr/lib/libtorrent.so.21 \
    /usr/lib/libtorrent.so.21.0.0 \
    /usr/lib

RUN mkdir -p /config /data

# Run as 1000:1001 user
ENV HOME=/config
USER 1000:1001
VOLUME /config
VOLUME /data

# rTorrent
ENTRYPOINT ["rtorrent", "-n", "-o", "system.daemon.set=true,import=/config/.rtorrent.rc"]
