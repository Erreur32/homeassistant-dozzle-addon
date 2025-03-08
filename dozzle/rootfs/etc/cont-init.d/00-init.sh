#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Minimal initialization
# ==============================================================================

# Check if bashio is available
if ! command -v bashio >/dev/null 2>&1; then
    echo "Error: bashio command not found. This addon requires bashio to function properly."
    exit 1
fi

bashio::log.info "Initializing Dozzle..."

# Check Docker socket access
if [ ! -S /var/run/docker.sock ]; then
    bashio::log.warning "Docker socket is not accessible!"
fi

# Check Dozzle executable
if [ ! -x /usr/local/bin/dozzle ]; then
    bashio::log.error "Dozzle executable not found or not executable!"
    exit 1
fi

# Check run.sh script
if [ ! -x /run.sh ]; then
    bashio::log.warning "run.sh script not found or not executable!"
    chmod +x /run.sh 2>/dev/null || bashio::log.error "Failed to make run.sh executable"
fi

bashio::log.info "Initialization completed." 