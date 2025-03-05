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

# Base command with address binding for external access
CMD="dozzle --addr 0.0.0.0:${PORT}"

# Vérifier si l'ingress est correctement configuré
if [[ -z "${INGRESS_ENTRY}" ]]; then
    bashio::log.warning "Ingress entry point is empty, starting without base path"
else
    bashio::log.info "Using base path: '${INGRESS_ENTRY}'"
    CMD="${CMD} --base ${INGRESS_ENTRY}"
fi

# Assurez-vous que le port est correctement configuré pour l'accès externe
if [[ "${REMOTE_ACCESS}" = "true" ]]; then
    bashio::log.info "Remote access enabled via port binding to 0.0.0.0"
fi

# Enable agent mode if configured
if [[ "${DOZZLE_AGENT_ENABLED}" = "true" ]]; then
    bashio::log.info "Agent mode enabled on port ${DOZZLE_AGENT_PORT}"
    CMD="${CMD} --agent --agent-addr 0.0.0.0:${DOZZLE_AGENT_PORT}"
fi

# Démarrer Dozzle avec la configuration mise à jour
bashio::log.info "Starting Dozzle on port ${PORT}"
bashio::log.debug "Command: ${CMD}"

# Exécuter Dozzle directement
exec ${CMD}