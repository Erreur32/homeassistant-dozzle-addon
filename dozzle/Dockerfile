ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.15
FROM $BUILD_FROM

LABEL maintainer="erreur32"

# Installer les dépendances nécessaires
RUN apk del go
RUN apk add --no-cache docker-cli jq curl git && \
    curl -sSL https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/bin/go

# Télécharger et compiler Dozzle
WORKDIR /opt/dozzle
RUN git clone --depth=1 https://github.com/amir20/dozzle.git . &&     go mod tidy &&     go build -o /usr/bin/dozzle &&     chmod +x /usr/bin/dozzle

# Nettoyage
RUN rm -rf /opt/dozzle

# Copier le script de démarrage
COPY dozzle/run.sh /run.sh

RUN chmod +x /run.sh

# Définir le point d’entrée
CMD [ "/run.sh" ]
