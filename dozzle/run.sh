#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

# Get config values
LOG_LEVEL=$(bashio::config 'log_level')
REMOTE_ACCESS=$(bashio::config 'remote_access')
PORT=$(bashio::config 'port')
DOZZLE_AGENT_ENABLED=$(bashio::config 'dozzle_agent_enabled')
DOZZLE_AGENT_PORT=$(bashio::config 'dozzle_agent_port')

# Set default values if not provided
if [[ -z "${DOZZLE_AGENT_PORT}" ]]; then
    DOZZLE_AGENT_PORT=7007
fi

# Get ingress entry point from Home Assistant
INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Ingress entry point: '${INGRESS_ENTRY}'"

# Build command - Use port from config
# Trim whitespace from INGRESS_ENTRY
INGRESS_ENTRY=$(echo "${INGRESS_ENTRY}" | xargs)

if [[ -z "${INGRESS_ENTRY}" ]]; then
    bashio::log.warning "Ingress entry point is empty, starting without base path"
    CMD="dozzle --addr 0.0.0.0:${PORT}"
else
    bashio::log.info "Using base path: '${INGRESS_ENTRY}'"
    CMD="dozzle --addr 0.0.0.0:${PORT} --base ${INGRESS_ENTRY}"
fi

# Remote access is handled by Home Assistant, no need for additional flags
# [[ "${REMOTE_ACCESS}" = "true" ]] && CMD="${CMD} --accept-remote-addr=.*"

if [[ "${DOZZLE_AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled on port ${DOZZLE_AGENT_PORT}"
    CMD="${CMD} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
fi

bashio::log.info "Starting Dozzle on port ${PORT}"
bashio::log.debug "Command: ${CMD}"

# Run Dozzle directly
exec ${CMD}