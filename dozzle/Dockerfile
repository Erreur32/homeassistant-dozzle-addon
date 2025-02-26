# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
# Utilisation de l’image de base de Home Assistant
# Use Home Assistant base image
ARG BUILD_FROM
FROM $BUILD_FROM
LABEL maintainer="erreur32"

# Install Bashio in a global path
RUN curl -sSL https://raw.githubusercontent.com/hassio-addons/bashio/main/lib/bashio -o /usr/bin/bashio \
    && curl -sSL https://raw.githubusercontent.com/hassio-addons/bashio/main/lib/bashio.sh -o /usr/bin/bashio.sh \
    && chmod +x /usr/bin/bashio /usr/bin/bashio.sh

# Install Dozzle safely
RUN wget -O /usr/bin/dozzle https://github.com/amir20/dozzle/releases/latest/download/dozzle-linux-amd64 \
    && chmod +x /usr/bin/dozzle \
    && ls -lh /usr/bin/dozzle  # Vérifier que le fichier est bien téléchargé

# Copy the startup script into the container
COPY dozzle/run.sh /run.sh
RUN chmod +x /run.sh

# Set the default command to execute the startup script
CMD [ "/run.sh" ]
