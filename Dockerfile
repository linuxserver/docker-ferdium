FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG FERDIUM_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Ferdium

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/ferdium-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    libatspi2.0-0 \
    libgtk-3-0 \
    libnotify4 \
    libsecret-1-0 && \
  echo "**** install from ferdium from deb ****" && \
  if [ -z ${FERDIUM_VERSION+x} ]; then \
    FERDIUM_VERSION=$(curl -sX GET "https://api.github.com/repos/ferdium/ferdium-app/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  cd /tmp && \
  curl -o \
    /tmp/ferdium.deb -L \
    "https://github.com/ferdium/ferdium-app/releases/download/${FERDIUM_VERSION}/Ferdium-linux-$(echo $FERDIUM_VERSION | sed 's/^v//g')-amd64.deb" && \
  dpkg -i ferdium.deb && \
  sed -i 's|</applications>|  <application title="Ferdium*" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
