#!/usr/bin/with-contenv bashio

# Enable job control
set -m

# Get config values
bashio::log.info "Starting Dozzle..."

# Function to clean Docker logs
clean_docker_logs() {
    bashio::log.info "Cleaning Docker container logs..."
    find /var/lib/docker/containers/ -type f -name "*.log" -exec truncate -s 0 {} \;
    bashio::log.info "Docker logs cleaned successfully"
}

# Get the port from config or use default
PORT=8099

# Get the log level from config or use default
if bashio::config.has_value 'log_level'; then
    LOG_LEVEL=$(bashio::config 'log_level')
else
    LOG_LEVEL="info"
fi

# Configure logging
bashio::log.level "${LOG_LEVEL}"

# Check for auto-update
if bashio::config.true 'auto_update'; then
    bashio::log.info "Auto-update enabled. Checking for updates..."
    apk update && apk upgrade
fi

# Check Docker socket access
if [ ! -S "/var/run/docker.sock" ]; then
    bashio::log.error "Docker socket not found at /var/run/docker.sock"
    exit 1
fi

if [ ! -f "/usr/local/bin/dozzle" ]; then
    bashio::log.error "Dozzle binary not found in /usr/local/bin/dozzle"
    exit 1
fi

# Clean logs at startup if enabled
if bashio::config.true 'clean_logs_on_start'; then
    bashio::log.info "Auto-clean logs enabled. Cleaning logs..."
    clean_docker_logs
else
    bashio::log.info "Auto-clean logs disabled. Skipping log cleanup."
fi

# Set environment variables for ingress support
export DOZZLE_BASE="/ingress"
export DOZZLE_ADDR="0.0.0.0:${PORT}"
export DOZZLE_NO_ANALYTICS="true"

# Log configuration
bashio::log.info "Dozzle configuration:"
bashio::log.info "Address: ${DOZZLE_ADDR}"
bashio::log.info "Base path: ${DOZZLE_BASE}"
bashio::log.info "External access: http://homeassistant:${PORT}"

# Start Dozzle
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
