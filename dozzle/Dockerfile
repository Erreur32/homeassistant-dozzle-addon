# Utilisation de l’image de base de Home Assistant
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.15
FROM $BUILD_FROM

LABEL maintainer="erreur32"

# Installer les dépendances nécessaires
RUN apk add --no-cache docker-cli jq curl git go nodejs npm yarn

# Télécharger et compiler Dozzle
WORKDIR /opt/dozzle
RUN git clone https://github.com/amir20/dozzle.git . && \
    go mod tidy && \
    yarn install && yarn build && \
    go build -o /usr/bin/dozzle && \
    chmod +x /usr/bin/dozzle


# Nettoyage
RUN rm -rf /opt/dozzle

# Copier le script de démarrage
COPY dozzle/run.sh /run.sh

RUN chmod +x /run.sh

# Définir le point d’entrée
CMD [ "/run.sh" ]
