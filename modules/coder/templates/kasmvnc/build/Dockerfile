ARG BASE_IMAGE="kasmweb/core-ubuntu-focal:1.11.0"
FROM $BASE_IMAGE

USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########
# Disable Printer
ENV KASM_SVC_PRINTER 0
# Disable Webcam
ENV KASM_SVC_WEBCAM 0
# Disable Gamepad
ENV KASM_SVC_GAMEPAD 0
# Disable Upload
ENV KASM_SVC_UPLOADS 0
# Disable Audio
ENV START_PULSEAUDIO 0
ENV KASM_SVC_AUDIO 0
ENV KASM_SVC_AUDIO_INPUT 0

# Disable HTTPS
RUN sed -i 's/-sslOnly/-SecurityTypes None -DisableBasicAuth 1/' $STARTUPDIR/vnc_startup.sh

# Install sudo
RUN apt-get update \
    && apt-get install -y sudo \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/list/*

# Install coder agent
RUN echo "#!/usr/bin/env bash" >> $STARTUPDIR/custom_startup.sh \
    && chmod 755 $STARTUPDIR/custom_startup.sh

ARG CODER_INIT_SCRIPT
RUN echo "${CODER_INIT_SCRIPT}" > /coder \
    && chmod +x /coder 
RUN echo "sudo --preserve-env sh -c '/coder 2>&1 > /var/log/coder-init.log &'" >> $STARTUPDIR/custom_startup.sh

ARG INSTALL_SCRIPT
RUN sh -c "${INSTALL_SCRIPT}"

ARG APP_TO_RUN
RUN echo "${APP_TO_RUN:="echo 'No app to run'"}" >> $STARTUPDIR/custom_startup.sh \
    && echo "tail -f /dev/null" >> $STARTUPDIR/custom_startup.sh

# Update the desktop environment to be optimized for a single application
# ENV SINGLE_APPLICATION=1
# RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
# RUN cp /usr/share/extra/backgrounds/bg_kasm.png /usr/share/extra/backgrounds/bg_default.png

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
