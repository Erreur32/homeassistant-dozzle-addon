# Use Home Assistant base image
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM
LABEL maintainer="erreur32"

# Install necessary dependencies (Dozzle + Bashio)
RUN apk add --no-cache docker-cli jq curl \
    && wget -O /usr/bin/bashio https://raw.githubusercontent.com/hassio-addons/bashio/main/bashio \
    && chmod +x /usr/bin/bashio

# Install Dozzle
RUN wget -O /usr/bin/dozzle https://github.com/amir20/dozzle/releases/latest/download/dozzle-linux-amd64 \
    && chmod +x /usr/bin/dozzle

# Copy the startup script into the container
COPY run.sh /
RUN chmod +x /run.sh

# Set the default command to execute the startup script
CMD [ "/run.sh" ]
