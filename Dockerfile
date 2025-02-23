# Use Home Assistant base image
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM
LABEL maintainer="tonpseudo"

# Install required dependencies
RUN apk add --no-cache docker-cli python3 py3-pip py3-virtualenv bashio

# Copy the startup script into the container
COPY run.sh /
RUN chmod +x /run.sh

# Set the default command to execute the startup script
CMD [ "/run.sh" ]
