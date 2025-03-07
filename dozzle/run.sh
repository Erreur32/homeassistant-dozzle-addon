#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

# Check if script is already running
LOCK_FILE="/tmp/dozzle.lock"
if [ -f "$LOCK_FILE" ]; then
    bashio::log.warning "Dozzle script is already running"
    exit 0
fi
touch "$LOCK_FILE"

# Cleanup lock file on exit
trap 'rm -f "$LOCK_FILE"' EXIT

# Get config values
LOG_LEVEL=$(bashio::config 'LogLevel')
AGENT_ENABLED=$(bashio::config 'DozzleAgent')
EXTERNAL_ACCESS=$(bashio::config 'ExternalAccess')

# Get ingress port and entry point from Home Assistant
INGRESS_PORT=$(bashio::addon.ingress_port)
INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Ingress entry point: '${INGRESS_ENTRY}'"
bashio::log.info "Ingress port: ${INGRESS_PORT}"

# Always listen on all interfaces for both ingress and external access
CMD="dozzle --addr 0.0.0.0:${INGRESS_PORT} --base ${INGRESS_ENTRY} --no-analytics"

# Add log level if specified
if [ -n "${LOG_LEVEL}" ]; then
    CMD="${CMD} --level ${LOG_LEVEL}"
fi

# Enable agent mode if configured
if [[ "${AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled on port 7007"
    CMD="${CMD} --agent --agent-addr 0.0.0.0:7007"
fi

# Log access mode
if [[ "${EXTERNAL_ACCESS}" = "true" ]]; then
    bashio::log.info "External access enabled"
else
    bashio::log.info "Only ingress access enabled"
fi

# Debug final configuration
bashio::log.debug "Dozzle Configuration:"
bashio::log.debug "  - Ingress Port: ${INGRESS_PORT}"
bashio::log.debug "  - Base Path: ${INGRESS_ENTRY}"
bashio::log.debug "  - Command: ${CMD}"

# Start Dozzle
bashio::log.info "Starting Dozzle..."
exec ${CMD}