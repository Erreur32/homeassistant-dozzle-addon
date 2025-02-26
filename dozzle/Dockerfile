# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
# Utilisation de l’image de base de Home Assistant
# Use Home Assistant base image
ARG BUILD_FROM
FROM $BUILD_FROM
LABEL maintainer="erreur32"

# Install Bashio in a global path
#RUN curl -sSL https://raw.githubusercontent.com/hassio-addons/bashio/main/lib/bashio -o /usr/bin/bashio \
#    && curl -sSL https://raw.githubusercontent.com/hassio-addons/bashio/main/lib/bashio.sh -o /usr/bin/bashio.sh \
#    && chmod +x /usr/bin/bashio /usr/bin/bashio.sh

# Installer les dépendances nécessaires
RUN apk add --no-cache docker-cli jq curl

# Créer le répertoire pour Bashio
RUN mkdir -p /usr/lib/bashio

# Télécharger les fichiers Bashio
RUN curl -sSL https://raw.githubusercontent.com/hassio-addons/bashio/main/lib/bashio \
    -o /usr/lib/bashio/bashio \
    && curl -sSL https://raw.githubusercontent.com/hassio-addons/bashio/main/lib/bashio.sh \
    -o /usr/lib/bashio/bashio.sh

# Rendre les fichiers exécutables
RUN chmod +x /usr/lib/bashio/bashio /usr/lib/bashio/bashio.sh

RUN apk add --no-cache git go && \
    git clone --depth=1 https://github.com/amir20/dozzle.git /opt/dozzle && \
    cd /opt/dozzle && go build -o /usr/bin/dozzle && \
    chmod +x /usr/bin/dozzle && \
    rm -rf /opt/dozzle

# Copy the startup script into the container
COPY dozzle/run.sh /run.sh
RUN chmod +x /run.sh

# Set the default command to execute the startup script
CMD [ "/run.sh" ]



