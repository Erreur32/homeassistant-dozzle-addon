ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.15
FROM $BUILD_FROM

LABEL maintainer="erreur32"

# Installer les dépendances nécessaires
RUN apk add --no-cache docker-cli jq curl git nodejs npm yarn

# Télécharger bashio avec le bon lien
RUN wget -O /usr/bin/bashio https://raw.githubusercontent.com/hassio-addons/bashio/refs/heads/main/lib/bashio \
    && chmod +x /usr/bin/bashio

# Installer Go 1.24.0 manuellement
RUN curl -sSL https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/bin/go

# Cloner et compiler Dozzle depuis la branche master (qui contient le dossier ui)
WORKDIR /opt/dozzle
RUN git clone --depth=1 --branch master https://github.com/amir20/dozzle.git . && \
    cd ui && yarn install && yarn build && cd .. && \
    mv ui/dist . && \
    go mod tidy && \
    go build -o /usr/bin/dozzle && \
    chmod +x /usr/bin/dozzle

# Nettoyer le répertoire de build
RUN rm -rf /opt/dozzle

# Copier le script de démarrage
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Point d'entrée
CMD [ "/run.sh" ]
