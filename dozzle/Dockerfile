# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
# Utilisation de l’image de base de Home Assistant
# Use Home Assistant base image
ARG BUILD_FROM
FROM $BUILD_FROM
LABEL maintainer="erreur32"
# Install necessary dependencies (Dozzle + Bashio)
RUN mkdir -p /usr/lib/bashio \
    && curl -sSL https://raw.githubusercontent.com/hassio-addons/bashio/main/lib/bashio -o /usr/lib/bashio/bashio \
    && curl -sSL https://raw.githubusercontent.com/hassio-addons/bashio/main/lib/bashio.sh -o /usr/lib/bashio/bashio.sh \
    && chmod +x /usr/lib/bashio/bashio \
    && chmod +x /usr/lib/bashio/bashio.sh


# Install Dozzle
RUN wget -O /usr/bin/dozzle https://github.com/amir20/dozzle/releases/latest/download/dozzle-linux-amd64 \
    && chmod +x /usr/bin/dozzle

# Copy the startup script into the container
COPY dozzle/run.sh /run.sh

RUN chmod +x /run.sh

# Set the default command to execute the startup script
CMD [ "/run.sh" ]
