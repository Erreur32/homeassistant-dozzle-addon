#FROM --platform=$BUILDPLATFORM ghcr.io/home-assistant/${BUILD_ARCH}-base:3.15

# Définition de l'architecture

ARG BUILD_ARCH=amd64
ARG BUILDPLATFORM

LABEL maintainer="erreur32"
LABEL \
    io.hass.name="Dozzle" \
    io.hass.description="Real-time Docker log monitoring interface for Home Assistant" \
    io.hass.type="addon" \
    io.hass.version="0.1.49" \
    dozzle.version="8.11.7"
LABEL io.hass.arch="${BUILD_ARCH}"
LABEL io.hass.url="https://github.com/Erreur32/homeassistant-dozzle-addon"

# ✅ Configuration du mode "host" pour Docker
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Mettre à jour les dépôts et installer libc6-compat
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update && apk add --no-cache libc6-compat

# Installation de glibc
RUN apk del --purge gcompat \
    && apk add --no-cache --force-overwrite libc6-compat \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk \
    && apk add --allow-untrusted --force-overwrite glibc-2.35-r1.apk \
    && rm -f glibc-2.35-r1.apk

# Vérification de glibc
RUN ldd --version || true

# Configuration de Dozzle
COPY bin/dozzle /usr/local/bin/dozzle
RUN chmod +x /usr/local/bin/dozzle

# Script de démarrage
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Copier le répertoire rootfs
COPY rootfs /

# S'assurer que tous les scripts sont exécutables
RUN chmod +x /etc/cont-init.d/* /etc/services.d/*/run /etc/services.d/*/finish

# Configuration S6
RUN mkdir -p /run/s6/container_environment
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Point d'entrée
ENTRYPOINT ["/init"]

