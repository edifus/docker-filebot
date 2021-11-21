FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
LABEL maintainer="edifus"
LABEL org.opencontainers.image.source https://github.com/edifus/docker-filebot

# environment variables
ENV HOME /config
ENV LANG C.UTF-8

# install filebot
RUN set -eux && \
  echo "**** adding repositories ****" && \
  apt-key adv --fetch-keys https://raw.githubusercontent.com/filebot/plugins/master/gpg/maintainer.pub && \
  echo "deb [arch=all] https://get.filebot.net/deb/ universal main" > /etc/apt/sources.list.d/filebot.list && \
  apt-get update && \
  echo "**** installing dependencies ****" && \
  apt-get install -y \
    default-jre-headless \
    libjna-java \
    mediainfo \
    libchromaprint-tools \
    unrar \
    p7zip-full \
    p7zip-rar \
    xz-utils \
    mkvtoolnix \
    atomicparsley \
    sudo \
    gnupg \
    curl \
    file \
    inotify-tools \
    jq && \
  echo '**** installing filebot ****' && \
  apt-get install -y --no-install-recommends filebot && \
  echo '**** appling custom docker configuration ****' && \
  sed -i \
    -e 's/APP_DATA=.*/APP_DATA="$HOME"/g' \
    -e 's/-Dapplication.deployment=deb/-Dapplication.deployment=docker/g' \
    /usr/bin/filebot && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rvf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# copy files
COPY rootfs/ /
