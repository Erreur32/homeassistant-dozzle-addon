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

    # Load config values with defaults
    port=$(bashio::config 'port' 8099)
    base="/"
    agent=$(bashio::config 'agent' false)
    agent_port=$(bashio::config 'agent_port' 7007)
    clean_logs=$(bashio::config 'clean_logs_on_start' false)
    log_level=$(bashio::config 'log_level' 'info')

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

    # Log configuration
    bashio::log.info "Starting Dozzle..."
    bashio::log.info "Port: ${port}"
    bashio::log.info "Base: ${base}"
    bashio::log.info "Agent mode: ${agent}"
    bashio::log.info "Agent port: ${agent_port}"
    bashio::log.info "Clean logs: ${clean_logs}"
    bashio::log.info "Log level: ${log_level}"

    # Start Dozzle
    if [ "$agent" = true ]; then
        bashio::log.info "Starting in agent mode..."
        exec dozzle --agent --port "${agent_port}"
    else
        exec dozzle --port "${port}"
    fi
}

# ==============================================================================
# EXECUTE LOGIC
# ------------------------------------------------------------------------------
main "$@"

# Démarrer Dozzle
#exec /usr/local/bin/dozzle --addr :${PORT}
# Lancer en arrière-plan pour éviter les conflits PID avec s6
#nohup /usr/local/bin/dozzle --addr :${PORT} > /dev/stdout 2>&1 &

# Run the Dozzle container with the necessary configurations
#docker run --rm \
#    --network=host \  # Use the host network mode to ensure full connectivity
#    -e DOZZLE_BASE=/api/panel \  # Set the base path for Dozzle when running in Home Assistant
#    -v /var/run/docker.sock:/var/run/docker.sock \  # Mount the Docker socket to allow access to logs
#    amir20/dozzle:latest
