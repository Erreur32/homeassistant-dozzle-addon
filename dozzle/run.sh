#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

# Get config values
LOG_LEVEL=$(bashio::config 'log_level')
REMOTE_ACCESS=$(bashio::config 'remote_access')
DOZZLE_AGENT_ENABLED=$(bashio::config 'dozzle_agent_enabled')
DOZZLE_AGENT_PORT=$(bashio::config 'dozzle_agent_port')

# Internal Dozzle ports
INTERNAL_PORT_INGRESS=8080
INTERNAL_PORT_EXTERNAL=8081

# Default external port (will be changed by HA if not available)
DEFAULT_EXTERNAL_PORT=8099

# Get external port from Home Assistant
EXTERNAL_PORT=$(bashio::addon.port ${DEFAULT_EXTERNAL_PORT})
if [[ -z "${EXTERNAL_PORT}" ]]; then
    EXTERNAL_PORT=${DEFAULT_EXTERNAL_PORT}
    bashio::log.info "Using default external port ${DEFAULT_EXTERNAL_PORT}"
fi

# Handle graceful shutdown
cleanup() {
    bashio::log.info "Shutting down Dozzle instances gracefully..."
    if [[ -n "${PID_INGRESS}" ]]; then
        kill -TERM "${PID_INGRESS}" || true
        wait "${PID_INGRESS}" || true
    fi
    if [[ -n "${PID_EXTERNAL}" ]]; then
        kill -TERM "${PID_EXTERNAL}" || true
        wait "${PID_EXTERNAL}" || true
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

# Get ingress entry point from Home Assistant
INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Ingress entry point: '${INGRESS_ENTRY}'"

# Trim whitespace from INGRESS_ENTRY
INGRESS_ENTRY=$(echo "${INGRESS_ENTRY}" | xargs)

# Start Ingress instance with unique ID and no analytics
CMD_INGRESS="dozzle --addr 0.0.0.0:${INTERNAL_PORT_INGRESS} --id dozzle_ingress --no-analytics"
if [[ -n "${INGRESS_ENTRY}" ]]; then
    bashio::log.info "Using base path for Ingress: '${INGRESS_ENTRY}'"
    CMD_INGRESS="${CMD_INGRESS} --base ${INGRESS_ENTRY}"
fi

# Start External instance if enabled
if [[ "${REMOTE_ACCESS}" = "true" ]]; then
    # External instance with unique ID and no analytics
    CMD_EXTERNAL="dozzle --addr 0.0.0.0:${INTERNAL_PORT_EXTERNAL} --id dozzle_external --no-analytics"
    if [[ -n "${EXTERNAL_PORT}" ]]; then
        bashio::log.info "Remote access enabled - External port: ${EXTERNAL_PORT}"
        if [[ "${EXTERNAL_PORT}" != "${DEFAULT_EXTERNAL_PORT}" ]]; then
            bashio::log.info "Note: Using alternative port ${EXTERNAL_PORT} instead of default ${DEFAULT_EXTERNAL_PORT}"
        fi
    else
        bashio::log.warning "Remote access enabled but no external port could be assigned"
    fi
fi

# Enable agent mode if configured
if [[ "${DOZZLE_AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled on port ${DOZZLE_AGENT_PORT}"
    CMD_INGRESS="${CMD_INGRESS} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
    [[ -n "${CMD_EXTERNAL}" ]] && CMD_EXTERNAL="${CMD_EXTERNAL} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
fi

# Start Dozzle instances
bashio::log.info "Starting Dozzle Ingress instance on port ${INTERNAL_PORT_INGRESS}"
bashio::log.debug "Ingress Command: ${CMD_INGRESS}"
${CMD_INGRESS} &
PID_INGRESS=$!

if [[ "${REMOTE_ACCESS}" = "true" ]]; then
    bashio::log.info "Starting Dozzle External instance on port ${INTERNAL_PORT_EXTERNAL}"
    bashio::log.debug "External Command: ${CMD_EXTERNAL}"
    ${CMD_EXTERNAL} &
    PID_EXTERNAL=$!
fi

# Wait for processes to end
wait $PID_INGRESS
[[ -n "${PID_EXTERNAL}" ]] && wait $PID_EXTERNAL