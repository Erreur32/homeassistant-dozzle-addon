# Utilisation de l’image de base de Home Assistant
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM
LABEL maintainer="erreur32"

# Installer les dépendances nécessaires (Docker CLI, jq, curl, git, Go)
RUN apk add --no-cache docker-cli jq curl git go

# Télécharger et compiler Dozzle
RUN git clone --depth=1 https://github.com/amir20/dozzle.git /opt/dozzle && \
    cd /opt/dozzle && go build -o /usr/bin/dozzle && \
    chmod +x /usr/bin/dozzle && \
    rm -rf /opt/dozzle

# Copier le script de démarrage
COPY dozzle/run.sh /run.sh
RUN chmod +x /run.sh

# Définir le point d’entrée
CMD [ "/run.sh" ]
