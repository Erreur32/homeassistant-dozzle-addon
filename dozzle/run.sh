#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

# Get config values
LOG_LEVEL=$(bashio::config 'log_level')
REMOTE_ACCESS=$(bashio::config 'remote_access')
DOZZLE_AGENT_ENABLED=$(bashio::config 'dozzle_agent_enabled')
DOZZLE_AGENT_PORT=$(bashio::config 'dozzle_agent_port')

# Internal Dozzle port (fixed)
INTERNAL_PORT=8080

# Get ingress entry point from Home Assistant
INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Ingress entry point: '${INGRESS_ENTRY}'"

# Trim whitespace from INGRESS_ENTRY
INGRESS_ENTRY=$(echo "${INGRESS_ENTRY}" | xargs)

# Base command with internal port binding
CMD="dozzle --addr 0.0.0.0:${INTERNAL_PORT}"

# Check if ingress is properly configured
if [[ -z "${INGRESS_ENTRY}" ]]; then
    bashio::log.warning "Ingress entry point is empty, starting without base path"
else
    bashio::log.info "Using base path: '${INGRESS_ENTRY}'"
    CMD="${CMD} --base ${INGRESS_ENTRY}"
fi

# Configure external access if enabled
if [[ "${REMOTE_ACCESS}" = "true" ]]; then
    bashio::log.info "Remote access enabled via port binding to 0.0.0.0"
fi

# Enable agent mode if configured
if [[ "${DOZZLE_AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled on port ${DOZZLE_AGENT_PORT}"
    CMD="${CMD} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
fi

# Start Dozzle with updated configuration
bashio::log.info "Starting Dozzle on internal port ${INTERNAL_PORT}"
bashio::log.debug "Command: ${CMD}"

# Execute Dozzle
exec ${CMD}