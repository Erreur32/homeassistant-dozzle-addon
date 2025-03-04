#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

# Get config values
LOG_LEVEL=$(bashio::config 'log_level')
REMOTE_ACCESS=$(bashio::config 'remote_access')
DOZZLE_PORT=$(bashio::config 'dozzle_port')
DOZZLE_AGENT_ENABLED=$(bashio::config 'dozzle_agent_enabled')
DOZZLE_AGENT_PORT=$(bashio::config 'dozzle_agent_port')

# No port check - Home Assistant handles port mapping

# Build command
CMD="dozzle --addr 0.0.0.0:${DOZZLE_PORT}"

# Add options based on config
[[ "${REMOTE_ACCESS}" = "true" ]] && CMD="${CMD} --accept-remote-addr=.*"

if [[ "${DOZZLE_AGENT_ENABLED}" = "true" ]]; then
    CMD="${CMD} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
fi

bashio::log.info "Starting Dozzle..."
bashio::log.debug "Command: ${CMD}"

# Run Dozzle
exec ${CMD}