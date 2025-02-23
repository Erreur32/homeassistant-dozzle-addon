# Dockerfile
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM
LABEL maintainer="tonpseudo"

# Install Docker CLI
RUN apk add --no-cache docker-cli

# Install Bashio from Home Assistant repository
RUN curl -fsSL https://raw.githubusercontent.com/hassio-addons/bashio/main/install.sh | bash -s


# Copy the startup script into the container
COPY run.sh /
RUN chmod +x /run.sh

# Set the default command to execute the startup script
CMD [ "/run.sh" ]
