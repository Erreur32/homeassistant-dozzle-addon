#!/usr/bin/with-contenv bashio
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
    local ssl
    local certfile
    local keyfile

    # Load config values with defaults
    port=$(bashio::config 'port' 8099)
    base="/"
    agent=$(bashio::config 'agent' false)
    agent_port=$(bashio::config 'agent_port' 7007)
    clean_logs=$(bashio::config 'clean_logs_on_start' false)
    log_level=$(bashio::config 'log_level' 'info')
    ssl=$(bashio::config 'ssl' false)
    certfile=$(bashio::config 'certfile' 'fullchain.pem')
    keyfile=$(bashio::config 'keyfile' 'privkey.pem')

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
    fi

    # SSL configuration
    if [ "$ssl" = true ]; then
        bashio::log.info "SSL is enabled"
        export DOZZLE_SSL_CERT="/ssl/${certfile}"
        export DOZZLE_SSL_KEY="/ssl/${keyfile}"
    fi

    # Log configuration
    bashio::log.info "Starting Dozzle..."
    bashio::log.info "Port: ${port}"
    bashio::log.info "Base: ${base}"
    bashio::log.info "Agent mode: ${agent}"
    bashio::log.info "Agent port: ${agent_port}"
    bashio::log.info "Clean logs: ${clean_logs}"
    bashio::log.info "Log level: ${log_level}"
    bashio::log.info "SSL: ${ssl}"

    # Start Dozzle with ingress support
    if [ "$agent" = true ]; then
        bashio::log.info "Starting in agent mode..."
        exec dozzle --agent --port "${agent_port}"
    else
        bashio::log.info "Starting with ingress support..."
        exec dozzle --port "${port}" --base "${base}"
    fi
}

# ==============================================================================
# EXECUTE LOGIC
# ------------------------------------------------------------------------------
main "$@"