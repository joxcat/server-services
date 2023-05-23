FROM ghcr.io/linuxserver/baseimage-kasmvnc:arch

ARG CODER_INIT_SCRIPT
RUN mkdir -p /custom-cont-init.d
RUN echo "${CODER_INIT_SCRIPT}" > /coder \
    && chmod +x /coder
RUN echo "#!/bin/sh" > /custom-cont-init.d/coder \
    && echo "/coder 2>&1 >/var/log/coder-init.log &" >> /custom-cont-init.d/coder

ARG APP_TO_RUN
RUN mkdir -p /defaults
RUN echo "${APP_TO_RUN}" > /defaults/autostart

ARG INSTALL_SCRIPT
RUN sh -c "${INSTALL_SCRIPT}"
