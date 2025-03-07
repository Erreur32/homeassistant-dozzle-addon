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

# Debug information
bashio::log.debug "Configuration loaded:"
bashio::log.debug "Log level: ${LOG_LEVEL}"
bashio::log.debug "Agent enabled: ${AGENT_ENABLED}"

# Debug Docker socket access
bashio::log.debug "Checking Docker socket access..."
if [ -S /var/run/docker.sock ]; then
    bashio::log.debug "Docker socket exists"
else
    bashio::log.warning "Docker socket not found at /var/run/docker.sock"
fi

# Get ingress entry point from Home Assistant
INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Ingress entry point: '${INGRESS_ENTRY}'"

# Trim whitespace from INGRESS_ENTRY
INGRESS_ENTRY=$(echo "${INGRESS_ENTRY}" | xargs)

# Start Dozzle with base configuration
CMD="dozzle --addr 0.0.0.0:8080 --base ${INGRESS_ENTRY} --no-analytics"

# Add log level if specified
if [ -n "${LOG_LEVEL}" ]; then
    CMD="${CMD} --level ${LOG_LEVEL}"
fi

# Enable agent mode if configured
if [[ "${AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled"
    CMD="${CMD} --agent --agent-addr 0.0.0.0:7007"
fi

# Debug final configuration
bashio::log.debug "Dozzle Configuration:"
bashio::log.debug "  - Port: 8080"
bashio::log.debug "  - Entry point: ${INGRESS_ENTRY}"
bashio::log.debug "  - Command: ${CMD}"

# Start Dozzle
bashio::log.info "Starting Dozzle..."
exec ${CMD}