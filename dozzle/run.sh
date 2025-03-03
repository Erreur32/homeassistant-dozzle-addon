#!/usr/bin/with-contenv bashio

# Enable job control
set -m

# Get config values
bashio::log.info "Starting Dozzle..."

# Get the port from config or use default
if bashio::config.has_value 'port'; then
    PORT=$(bashio::config 'port')
else
    PORT=8099
fi

# Get the log level from config or use default
if bashio::config.has_value 'log_level'; then
    LOG_LEVEL=$(bashio::config 'log_level')
else
    LOG_LEVEL="info"
fi

# Configure logging
bashio::log.level "${LOG_LEVEL}"

# Vérifie si la mise à jour automatique est activée
if bashio::config.true 'auto_update'; then
    bashio::log.info "Auto-update enabled. Checking for updates..."
    apk update && apk upgrade
fi

# Vérifier que le socket Docker est accessible
if [ ! -S "/var/run/docker.sock" ]; then
    bashio::log.error "Docker socket not found! Make sure it's mapped in Home Assistant."
    exit 1
fi

if [ ! -f "/usr/local/bin/dozzle" ]; then
    bashio::log.error "Dozzle binary not found in /usr/local/bin/dozzle"
    exit 1
fi

# Set the base path for ingress
export DOZZLE_BASE="/"
export DOZZLE_ADDR="0.0.0.0:${PORT}"
export DOZZLE_NO_ANALYTICS="true"

# Log configuration
bashio::log.info "Dozzle configuration:"
bashio::log.info "Address: ${DOZZLE_ADDR}"
bashio::log.info "Base path: ${DOZZLE_BASE}"

# Start Dozzle with proper configuration
exec /usr/local/bin/dozzle

# Démarrer Dozzle
#exec /usr/local/bin/dozzle --addr :${PORT}
# Lancer en arrière-plan pour éviter les conflits PID avec s6
#nohup /usr/local/bin/dozzle --addr :${PORT} > /dev/stdout 2>&1 &

# Run the Dozzle container with the necessary configurations
#docker run --rm \
#    --network=host \  # Use the host network mode to ensure full connectivity
#    -e DOZZLE_BASE=/api/panel \  # Set the base path for Dozzle when running in Home Assistant
#    -v /var/run/docker.sock:/var/run/docker.sock \  # Mount the Docker socket to allow access to logs
#    amir20/dozzle:latest
