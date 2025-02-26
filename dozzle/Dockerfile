# Use Home Assistant base image
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.15
FROM $BUILD_FROM

LABEL maintainer="erreur32"

# Installer les dépendances nécessaires
RUN apk add --no-cache docker-cli jq curl git nodejs npm yarn

# Install necessary dependencies (Dozzle + Bashio)
RUN apk add --no-cache docker-cli jq curl \
    && wget -O /usr/bin/bashio https://raw.githubusercontent.com/hassio-addons/bashio/refs/heads/main/lib/bashio \
    && chmod +x /usr/bin/bashio


# Installer Go 1.24.0 manuellement pour supporter la syntaxe du go.mod
RUN apk del go || true && \
    curl -sSL https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/bin/go

# Cloner et compiler Dozzle
WORKDIR /opt/dozzle
RUN git clone https://github.com/amir20/dozzle.git . && \
    cd ui && yarn install && yarn build && cd .. && \
    go mod tidy && \
    go build -o /usr/bin/dozzle && \
    chmod +x /usr/bin/dozzle

# Nettoyer le répertoire de build
RUN rm -rf /opt/dozzle


# Copy the startup script into the container
COPY dozzle/run.sh /
RUN chmod +x /run.sh

# Set the default command to execute the startup script
CMD [ "/run.sh" ]
