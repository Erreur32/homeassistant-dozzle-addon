#!/usr/bin/with-contenv bashio
set -e

# Get config values
LOG_LEVEL=$(bashio::config 'log_level')
REMOTE_ACCESS=$(bashio::config 'remote_access')
DOZZLE_PORT=$(bashio::config 'dozzle_port')
DOZZLE_AGENT_ENABLED=$(bashio::config 'dozzle_agent_enabled')
DOZZLE_AGENT_PORT=$(bashio::config 'dozzle_agent_port')
BASE=$(bashio::config 'base')
FILTER=$(bashio::config 'filter')
SHOW_HIDDEN=$(bashio::config 'show_hidden')
AUTH=$(bashio::config 'auth')

# Check if port is available
if ! bashio::port_is_available "${DOZZLE_PORT}"; then
    bashio::log.warning "Port ${DOZZLE_PORT} is already in use. Will try another port."
    DOZZLE_PORT=$(bashio::network.get_port "${DOZZLE_PORT}")
fi

# Build command
CMD="/app/dozzle --addr 0.0.0.0:${DOZZLE_PORT}"

# Add options based on config
[[ "${REMOTE_ACCESS}" = "true" ]] && CMD="${CMD} --accept-remote-addr=.*"
[[ -n "${BASE}" ]] && CMD="${CMD} --base ${BASE}"
[[ -n "${FILTER}" ]] && CMD="${CMD} --filter ${FILTER}"
[[ "${SHOW_HIDDEN}" = "true" ]] && CMD="${CMD} --show-hidden"
[[ "${AUTH}" = "true" ]] && CMD="${CMD} --auth"

if [[ "${DOZZLE_AGENT_ENABLED}" = "true" ]]; then
    CMD="${CMD} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
fi

bashio::log.info "Starting Dozzle..."
bashio::log.debug "Command: ${CMD}"

# Run Dozzle
exec ${CMD}