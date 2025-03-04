#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Minimal initialization
# ==============================================================================

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

bashio::log.info "Initialization completed." 