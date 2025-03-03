#!/usr/bin/with-contenv bashio

set -e

# Get config values
PORT=$(bashio::config 'port')
INGRESS_PATH=$(bashio::addon.ingress_entry)
SLUG=$(bashio::addon.slug)
LOG_LEVEL=$(bashio::config 'log_level')

# Configure logging
bashio::log.level "${LOG_LEVEL}"
bashio::log.info "Starting Dozzle with port ${PORT}..."

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
export DOZZLE_BASE="/api/hassio_ingress/${SLUG}"
export DOZZLE_ADDR="0.0.0.0:${PORT}"

# Log configuration
bashio::log.info "Dozzle configuration:"
bashio::log.info "Base path: ${DOZZLE_BASE}"
bashio::log.info "Address: ${DOZZLE_ADDR}"

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
