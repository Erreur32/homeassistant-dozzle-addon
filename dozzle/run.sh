#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# ==============================================================================

# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
    local dozzle_port
    local dozzle_agent_enabled
    local dozzle_agent_port

    # Load config values with defaults
    dozzle_port=$(bashio::config 'dozzle_port' 8099)
    dozzle_agent_enabled=$(bashio::config 'dozzle_agent_enabled' false)
    dozzle_agent_port=$(bashio::config 'dozzle_agent_port' 7007)

    # Check port availability
    if ! bashio::net.wait_for 8099; then
        bashio::log.error "Port 8099 is not available"
        exit 1
    fi

    # Log configuration
    bashio::log.info "Starting Dozzle..."
    bashio::log.info "Dozzle port: ${dozzle_port}"
    bashio::log.info "Dozzle Agent enabled: ${dozzle_agent_enabled}"
    bashio::log.info "Dozzle Agent port: ${dozzle_agent_port}"

    # Start Dozzle
    if [ "$dozzle_agent_enabled" = true ]; then
        bashio::log.info "Starting Dozzle Agent..."
        exec dozzle --agent --addr "0.0.0.0:${dozzle_agent_port}"
    else
        bashio::log.info "Starting Dozzle..."
        exec dozzle --addr "0.0.0.0:${dozzle_port}"
    fi
}

# ==============================================================================
# EXECUTE LOGIC
# ------------------------------------------------------------------------------
main "$@"