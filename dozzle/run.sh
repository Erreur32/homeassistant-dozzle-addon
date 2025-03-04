#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

# Get config values
LOG_LEVEL=$(bashio::config 'log_level')
REMOTE_ACCESS=$(bashio::config 'remote_access')
DOZZLE_AGENT_ENABLED=$(bashio::config 'dozzle_agent_enabled')
DOZZLE_AGENT_PORT=$(bashio::config 'dozzle_agent_port')
if [[ -z "${DOZZLE_AGENT_PORT}" ]]; then
    DOZZLE_AGENT_PORT=7007
fi

# Build command - Use fixed port 8099 for Dozzle
# Use 0.0.0.0 to make it accessible from both ingress and external
CMD="dozzle --addr 0.0.0.0:8099 --base /"

# Add options based on config
[[ "${REMOTE_ACCESS}" = "true" ]] && CMD="${CMD} --accept-remote-addr=.*"

if [[ "${DOZZLE_AGENT_ENABLED}" = "true" ]]; then
    CMD="${CMD} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
fi

bashio::log.info "Starting Dozzle on port 8099..."
bashio::log.debug "Command: ${CMD}"

# Run Dozzle
exec ${CMD}