ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.15
FROM $BUILD_FROM

LABEL maintainer="erreur32"

# Installer les dépendances nécessaires
RUN apk add --no-cache docker-cli jq curl git go

# Télécharger et compiler Dozzle
WORKDIR /opt/dozzle
RUN git clone --depth=1 https://github.com/amir20/dozzle.git . &&     go mod tidy &&     go build -o /usr/bin/dozzle &&     chmod +x /usr/bin/dozzle

# Nettoyage
RUN rm -rf /opt/dozzle

# Copier le script de démarrage
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Définir le point d’entrée
CMD [ "/run.sh" ]
