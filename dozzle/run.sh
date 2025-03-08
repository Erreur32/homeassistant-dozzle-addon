#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

# Check if bashio is available
if ! command -v bashio >/dev/null 2>&1; then
    echo "Error: bashio command not found. This addon requires bashio to function properly."
    exit 1
fi

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

# Get ingress port from configuration with fallback
INGRESS_PORT=$(bashio::addon.ingress_port)
# Check if INGRESS_PORT is a valid number
if ! [[ "$INGRESS_PORT" =~ ^[0-9]+$ ]]; then
    # If not a valid number, use the default from config.yaml
    bashio::log.warning "Invalid ingress port value: ${INGRESS_PORT}, using default 8080"
    INGRESS_PORT=8080
fi
bashio::log.info "Ingress port: ${INGRESS_PORT}"

# Get the port assigned by Home Assistant for external access
ASSIGNED_PORT=$(bashio::addon.port ${INGRESS_PORT})
if [ -z "${ASSIGNED_PORT}" ]; then
    ASSIGNED_PORT="${INGRESS_PORT}"
fi

# Debug information
bashio::log.debug "Configuration loaded:"
bashio::log.debug "Log level: ${LOG_LEVEL}"
bashio::log.debug "Agent enabled: ${AGENT_ENABLED}"
bashio::log.debug "External access: ${EXTERNAL_ACCESS}"
bashio::log.debug "Assigned port: ${ASSIGNED_PORT}"

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

# Build Dozzle command
if [[ "${EXTERNAL_ACCESS}" = "true" ]]; then
    CMD="dozzle --addr 0.0.0.0:${ASSIGNED_PORT} --no-analytics"
    bashio::log.info "External access enabled on port ${ASSIGNED_PORT}"
else
    CMD="dozzle --addr 127.0.0.1:${INGRESS_PORT} --base ${INGRESS_ENTRY} --no-analytics"
    bashio::log.info "Only ingress access enabled"
fi

# Add log level if specified
if [ -n "${LOG_LEVEL}" ]; then
    CMD="${CMD} --level ${LOG_LEVEL}"
fi

# Enable agent mode if configured
if [[ "${AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled on port 7007"
    CMD="${CMD} --agent --agent-addr 0.0.0.0:7007"
fi

# Debug final configuration
bashio::log.debug "Dozzle Configuration:"
bashio::log.debug "  - Ingress Port: ${INGRESS_PORT}"
[[ "${EXTERNAL_ACCESS}" = "true" ]] && bashio::log.debug "  - External Port: ${ASSIGNED_PORT}"
bashio::log.debug "  - Entry point: ${INGRESS_ENTRY}"
bashio::log.debug "  - Command: ${CMD}"

# Start Dozzle
bashio::log.info "Starting Dozzle..."
exec ${CMD}