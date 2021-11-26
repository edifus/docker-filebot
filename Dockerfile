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
  DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    default-jre-headless \
    libjna-java \
    libchromaprint-tools \
    libcurl3-gnutls \
    libmms0 \
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
  echo "**** install current mediainfo for focal ****" && \
  MEDIAINFO_VERSION=$(curl -sLX GET https://api.github.com/repos/MediaArea/MediaInfo/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  LIBZEN_VERSION=$(curl -sLX GET https://api.github.com/repos/MediaArea/ZenLib/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  curl -o /tmp/mediainfo.deb \
   -L "https://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VERSION#?}/mediainfo_${MEDIAINFO_VERSION#?}-1_amd64.xUbuntu_20.04.deb" && \
  curl -o /tmp/libmediainfo.deb \
   -L "https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VERSION#?}/libmediainfo0v5_${MEDIAINFO_VERSION#?}-1_amd64.xUbuntu_20.04.deb" && \
  curl -o /tmp/libzen.deb \
   -L "https://mediaarea.net/download/binary/libzen0/${LIBZEN_VERSION#?}/libzen0v5_${LIBZEN_VERSION#?}-1_amd64.xUbuntu_20.04.deb" && \
  dpkg -i /tmp/libzen.deb && \
  dpkg -i /tmp/libmediainfo.deb && \
  dpkg -i /tmp/mediainfo.deb && \
  echo '**** installing filebot ****' && \
  DEBIAN_FRONTEND=noninteractive \
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
