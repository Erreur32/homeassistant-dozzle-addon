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

# Default external port (will be changed by HA if not available)
DEFAULT_EXTERNAL_PORT=8099

# Get external port from Home Assistant (checking default port 8099 first)
EXTERNAL_PORT=$(bashio::addon.port ${DEFAULT_EXTERNAL_PORT})

# Handle graceful shutdown
cleanup() {
    bashio::log.info "Shutting down Dozzle gracefully..."
    kill -TERM "$PID"
    wait "$PID"
    exit 0
}

trap cleanup SIGTERM SIGINT

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
    if [[ -n "${EXTERNAL_PORT}" ]]; then
        if [[ "${EXTERNAL_PORT}" == "${DEFAULT_EXTERNAL_PORT}" ]]; then
            bashio::log.info "Remote access enabled on default port ${DEFAULT_EXTERNAL_PORT}"
        else
            bashio::log.info "Remote access enabled - Port ${DEFAULT_EXTERNAL_PORT} was busy, using port ${EXTERNAL_PORT}"
        fi
    else
        bashio::log.warning "Remote access enabled but no external port was assigned by Home Assistant"
    fi
fi

# Enable agent mode if configured
if [[ "${DOZZLE_AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled on port ${DOZZLE_AGENT_PORT}"
    CMD="${CMD} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
fi

# Start Dozzle with updated configuration
bashio::log.info "Starting Dozzle on internal port ${INTERNAL_PORT}"
bashio::log.debug "Command: ${CMD}"

# Execute Dozzle in background and store PID
${CMD} &
PID=$!

# Wait for process to end
wait "$PID"