# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
# Utilisation de l’image de base de Home Assistant
ARG BUILD_FROM
FROM $BUILD_FROM

LABEL maintainer="erreur32"

# Installer les dépendances nécessaires
RUN apk add --no-cache docker-cli jq curl \
    && wget -O /usr/bin/bashio https://raw.githubusercontent.com/hassio-addons/bashio/main/bashio \
    && chmod +x /usr/bin/bashio

# Installer Dozzle
RUN wget -O /usr/bin/dozzle https://github.com/amir20/dozzle/releases/latest/download/dozzle-linux-amd64 \
    && chmod +x /usr/bin/dozzle

# Copier les fichiers nécessaires
COPY rootfs/ /

# Définir la commande de lancement de l'add-on
CMD [ "/usr/bin/dozzle", "--host", "0.0.0.0", "--port", "8090" ]
