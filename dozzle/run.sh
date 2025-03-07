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

# Build base command
if [[ "${EXTERNAL_ACCESS}" = "true" ]]; then
    bashio::log.info "External access enabled"
    CMD="dozzle --addr 0.0.0.0:8080 --no-analytics"
else
    bashio::log.info "Only ingress access enabled"
    CMD="dozzle --addr 127.0.0.1:8080 --no-analytics"
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

# Start Dozzle
bashio::log.info "Starting Dozzle..."
exec ${CMD}