#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# ==============================================================================

# ==============================================================================
# RUN LOGIC
# ------------------------------------------------------------------------------
main() {
    local port
    local base
    local agent
    local agent_port
    local clean_logs
    local log_level

    # Load config values with defaults
    port=$(bashio::config 'port' 8099)
    base="/"
    agent=$(bashio::config 'agent' false)
    agent_port=$(bashio::config 'agent_port' 7007)
    clean_logs=$(bashio::config 'clean_logs_on_start' false)
    log_level=$(bashio::config 'log_level' 'info')

    # Check port availability
    if ! bashio::net.wait_for 8099; then
        bashio::log.error "Port 8099 is not available"
        exit 1
    fi

    # Clean logs if enabled
    if [ "$clean_logs" = true ]; then
        bashio::log.info "Cleaning Docker logs..."
        find /var/lib/docker/containers/ -type f -name "*.log" -exec truncate -s 0 {} \;
    fi

    # Set log level
    bashio::log.level "$log_level"

    # Export environment variables
    export DOZZLE_BASE="${base}"
    export DOZZLE_ADDR="0.0.0.0:${port}"
    export DOZZLE_TAILSIZE="1000"
    export DOZZLE_FOLLOW="true"
    export DOZZLE_JSON="true"
    export DOZZLE_WEBSOCKET="true"

    # Handle SUPERVISOR_TOKEN
    if bashio::var.has_value "${SUPERVISOR_TOKEN}"; then
        export SUPERVISOR_TOKEN="${SUPERVISOR_TOKEN}"
    else
        bashio::log.warning "SUPERVISOR_TOKEN not found, some features may be limited"
        export SUPERVISOR_TOKEN=""
    fi

    # Log configuration
    bashio::log.info "Starting Dozzle..."
    bashio::log.info "Port: ${port}"
    bashio::log.info "Base: ${base}"
    bashio::log.info "Agent mode: ${agent}"
    bashio::log.info "Agent port: ${agent_port}"
    bashio::log.info "Clean logs: ${clean_logs}"
    bashio::log.info "Log level: ${log_level}"
    bashio::log.info "Ingress enabled: true"

    # Start Dozzle with ingress support
    if [ "$agent" = true ]; then
        bashio::log.info "Starting in agent mode..."
        exec dozzle --agent --port "${agent_port}"
    else
        bashio::log.info "Starting with ingress support..."
        exec dozzle --port "${port}" --base "${base}" --addr "0.0.0.0:${port}"
    fi
}

# ==============================================================================
# EXECUTE LOGIC
# ------------------------------------------------------------------------------
main "$@"