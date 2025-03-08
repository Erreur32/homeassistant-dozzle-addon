# Set the architecture
ARG BUILD_ARCH
FROM ghcr.io/home-assistant/${BUILD_ARCH}-base:3.15

LABEL maintainer="erreur32"
LABEL \
    io.hass.name="Dozzle" \
    io.hass.description="Real-time Docker log monitoring interface for Home Assistant" \
    io.hass.type="addon" \
    io.hass.version="0.1.51" \
    dozzle.version="8.11.7"
LABEL io.hass.arch="${BUILD_ARCH}"
LABEL io.hass.url="https://github.com/Erreur32/homeassistant-dozzle-addon"

# Configuration of Docker host mode
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Update repositories and install dependencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update && apk add --no-cache \
        libc6-compat \
        jq \
        curl \
        bash \
        nginx \
        shadow \
        coreutils \
        findutils \
        grep

# Create symlinks for bash
RUN ln -sf /bin/bash /usr/bin/bash || true

# Install glibc
RUN apk del --purge gcompat \
    && apk add --no-cache --force-overwrite libc6-compat \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk \
    && apk add --allow-untrusted --force-overwrite glibc-2.35-r1.apk \
    && rm -f glibc-2.35-r1.apk

# Verify glibc
RUN ldd --version || true

# Configure Dozzle
COPY bin/dozzle /usr/local/bin/dozzle
RUN chmod +x /usr/local/bin/dozzle

# Startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Copy the rootfs directory
COPY rootfs /

# Ensure all scripts are executable and fix line endings
RUN find /etc/cont-init.d -type f -exec chmod +x {} \; || true
RUN find /etc/services.d -type f -name run -exec chmod +x {} \; || true
RUN find /etc/services.d -type f -name finish -exec chmod +x {} \; || true
RUN find /etc/cont-init.d -type f -exec sed -i 's/\r$//' {} \; || true
RUN find /etc/services.d -type f -exec sed -i 's/\r$//' {} \; || true
RUN sed -i 's/\r$//' /run.sh || true

# Create docker group with same GID as host
RUN addgroup -g 995 docker || true
RUN addgroup root docker || true

# S6 configuration
RUN mkdir -p /run/s6/container_environment
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Entry point
ENTRYPOINT ["/init"]
