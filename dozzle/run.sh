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
REMOTE_ACCESS=$(bashio::config 'ExternalAccess')
EXTERNAL_PORT=$(bashio::config 'ExternalPort')
SSL=$(bashio::config 'SSL_Enable')
SSL_CERT=$(bashio::config 'SSL_Certificate')
SSL_KEY=$(bashio::config 'SSL_Key')
AGENT_ENABLED=$(bashio::config 'DozzleAgent')
AGENT_PORT=$(bashio::config 'DozzleAgentPort')

# Debug information
bashio::log.debug "Configuration loaded:"
bashio::log.debug "Log level: ${LOG_LEVEL}"
bashio::log.debug "External access: ${REMOTE_ACCESS}"
bashio::log.debug "External port: ${EXTERNAL_PORT}"
bashio::log.debug "SSL enabled: ${SSL}"
bashio::log.debug "SSL cert: ${SSL_CERT}"
bashio::log.debug "SSL key: ${SSL_KEY}"
bashio::log.debug "Agent enabled: ${AGENT_ENABLED}"
bashio::log.debug "Agent port: ${AGENT_PORT}"

# Internal Dozzle ports
INTERNAL_PORT_INGRESS=8080
INTERNAL_PORT_EXTERNAL=8081

# Default external port (will be changed by HA if not available)
DEFAULT_EXTERNAL_PORT=8099

# Get external port from Home Assistant only if remote access is enabled
if [[ "${REMOTE_ACCESS}" = "true" ]]; then
    EXTERNAL_PORT=$(bashio::addon.port ${DEFAULT_EXTERNAL_PORT})
    if [[ -z "${EXTERNAL_PORT}" ]]; then
        EXTERNAL_PORT=${DEFAULT_EXTERNAL_PORT}
        bashio::log.info "Using default external port ${DEFAULT_EXTERNAL_PORT}"
    fi
else
    bashio::log.info "External access is disabled"
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
    rm -f "$LOCK_FILE"
    exit 0
}

trap cleanup SIGTERM SIGINT

# Get ingress entry point from Home Assistant
INGRESS_ENTRY=$(bashio::addon.ingress_entry)
bashio::log.info "Ingress entry point: '${INGRESS_ENTRY}'"

# Trim whitespace from INGRESS_ENTRY
INGRESS_ENTRY=$(echo "${INGRESS_ENTRY}" | xargs)

# Start Ingress instance with namespace and no analytics
CMD_INGRESS="dozzle --addr 0.0.0.0:${INTERNAL_PORT_INGRESS} --namespace dozzle_ingress --no-analytics"

# Use the ingress entry point directly from Home Assistant
if [ -n "${INGRESS_ENTRY}" ]; then
    bashio::log.info "Using Home Assistant ingress path: '${INGRESS_ENTRY}'"
    CMD_INGRESS="${CMD_INGRESS} --base ${INGRESS_ENTRY}"
fi

if [ -n "${LOG_LEVEL}" ]; then
    CMD_INGRESS="${CMD_INGRESS} --level ${LOG_LEVEL}"
fi

# Start Dozzle instances
bashio::log.info "Starting Dozzle Ingress instance on port ${INTERNAL_PORT_INGRESS}"
bashio::log.debug "Ingress Command: ${CMD_INGRESS}"
${CMD_INGRESS} &
PID_INGRESS=$!

# Wait for ingress to be ready (2 seconds)
sleep 2

# Debug ingress setup
bashio::log.debug "Testing ingress endpoint..."
if curl -s -I "http://localhost:${INTERNAL_PORT_INGRESS}/health" > /dev/null 2>&1; then
    bashio::log.info "Ingress endpoint is responding"
else
    bashio::log.warning "Failed to reach ingress endpoint"
fi

# Prepare External instance command if enabled
CMD_EXTERNAL=""
if [[ "${REMOTE_ACCESS}" = "true" ]]; then
    CMD_EXTERNAL="dozzle --addr 0.0.0.0:${INTERNAL_PORT_EXTERNAL} --namespace dozzle_external --no-analytics"
    
    # Add SSL if enabled
    if [[ "${SSL}" = "true" ]]; then
        if [[ -f "/ssl/${SSL_CERT}" ]] && [[ -f "/ssl/${SSL_KEY}" ]]; then
            CMD_EXTERNAL="${CMD_EXTERNAL} --ssl --ssl-cert /ssl/${SSL_CERT} --ssl-key /ssl/${SSL_KEY}"
            bashio::log.info "SSL enabled for external access"
        else
            bashio::log.warning "SSL certificates not found, starting without SSL"
        fi
    fi
    if [ -n "${LOG_LEVEL}" ]; then
        CMD_EXTERNAL="${CMD_EXTERNAL} --level ${LOG_LEVEL}"
    fi
    if [[ -n "${EXTERNAL_PORT}" ]]; then
        bashio::log.info "Remote access enabled - External port: ${EXTERNAL_PORT} (internal: ${INTERNAL_PORT_EXTERNAL})"
        if [[ "${EXTERNAL_PORT}" != "${DEFAULT_EXTERNAL_PORT}" ]]; then
            bashio::log.info "Note: Using alternative port ${EXTERNAL_PORT} instead of default ${DEFAULT_EXTERNAL_PORT}"
        fi
    else
        bashio::log.warning "Remote access enabled but no external port could be assigned"
    fi
fi

# Enable agent mode if configured
if [[ "${AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled on port ${AGENT_PORT}"
    CMD_INGRESS="${CMD_INGRESS} --agent --agent-addr 0.0.0.0:${AGENT_PORT}"
    [[ -n "${CMD_EXTERNAL}" ]] && CMD_EXTERNAL="${CMD_EXTERNAL} --agent --agent-addr 0.0.0.0:${AGENT_PORT}"
fi

# Start External instance if enabled
if [[ -n "${CMD_EXTERNAL}" ]]; then
    bashio::log.info "Starting Dozzle External instance (internal: ${INTERNAL_PORT_EXTERNAL}, external: ${EXTERNAL_PORT})"
    bashio::log.debug "External Command: ${CMD_EXTERNAL}"
    ${CMD_EXTERNAL} &
    PID_EXTERNAL=$!
fi

# Wait for processes to end
wait $PID_INGRESS
[[ -n "${PID_EXTERNAL}" ]] && wait $PID_EXTERNAL