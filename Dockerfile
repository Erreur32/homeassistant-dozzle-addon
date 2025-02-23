# Dockerfile
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM
LABEL maintainer="erreur32"

# Install Docker CLI
# Install Python3 and pip (required for Bashio)
RUN apk add --no-cache python3 py3-pip

# Install Bashio from Home Assistant repository
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

 

# Copy the startup script into the container
COPY run.sh /
RUN chmod +x /run.sh

# Set the default command to execute the startup script
CMD [ "/run.sh" ]
