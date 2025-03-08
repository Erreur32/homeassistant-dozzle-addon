#!/usr/bin/with-contenv bash
# shellcheck shell=bash
set -e

# Define paths
BASHIO_BIN="/usr/bin/bashio"
DOZZLE_BIN="/usr/local/bin/dozzle"

# Check if bashio is available
if [ -x "${BASHIO_BIN}" ]; then
    # Use bashio if available
    log_info() { ${BASHIO_BIN} log.info "$1"; }
    log_warning() { ${BASHIO_BIN} log.warning "$1"; }
    log_error() { ${BASHIO_BIN} log.error "$1"; }
    log_debug() { ${BASHIO_BIN} log.debug "$1"; }
    get_config() { ${BASHIO_BIN} config "$1"; }
    get_ingress_port() { ${BASHIO_BIN} addon.ingress_port; }
    get_addon_port() { ${BASHIO_BIN} addon.port "$1"; }
    get_ingress_entry() { ${BASHIO_BIN} addon.ingress_entry; }
else
    # Fallback to echo if bashio is not available
    echo "Warning: bashio not found at ${BASHIO_BIN}, using fallback logging"
    log_info() { echo "[INFO] $1"; }
    log_warning() { echo "[WARNING] $1"; }
    log_error() { echo "[ERROR] $1"; }
    log_debug() { echo "[DEBUG] $1"; }
    get_config() { echo "info"; } # Default value
    get_ingress_port() { echo "8080"; } # Default value
    get_addon_port() { echo "$1"; } # Return the same port
    get_ingress_entry() { echo "/"; } # Default value
fi

# Check if script is already running
LOCK_FILE="/tmp/dozzle.lock"
if [ -f "$LOCK_FILE" ]; then
    log_warning "Dozzle script is already running"
    exit 0
fi
touch "$LOCK_FILE"

# Cleanup lock file on exit
trap 'rm -f "$LOCK_FILE"' EXIT

# Check if Dozzle is available
if [ ! -x "${DOZZLE_BIN}" ]; then
    log_error "Dozzle executable not found at ${DOZZLE_BIN}"
    exit 1
fi

# Get Dozzle version
DOZZLE_VERSION=$(${DOZZLE_BIN} --version 2>&1 || echo "unknown")
log_info "Dozzle version: ${DOZZLE_VERSION}"

# Check if agent mode is supported
AGENT_SUPPORTED=false
if ${DOZZLE_BIN} --help 2>&1 | grep -q -- "--agent"; then
    AGENT_SUPPORTED=true
    log_info "Agent mode is supported in this version of Dozzle"
else
    log_warning "Agent mode is NOT supported in this version of Dozzle (${DOZZLE_VERSION})"
fi

# Get config values
LOG_LEVEL=$(get_config 'LogLevel')
AGENT_ENABLED=$(get_config 'DozzleAgent')
EXTERNAL_ACCESS=$(get_config 'ExternalAccess')

# Get ingress port from configuration with fallback
INGRESS_PORT=$(get_ingress_port)
# Check if INGRESS_PORT is a valid number
if ! [[ "$INGRESS_PORT" =~ ^[0-9]+$ ]]; then
    # If not a valid number, use the default from config.yaml
    log_warning "Invalid ingress port value: ${INGRESS_PORT}, using default 8080"
    INGRESS_PORT=8080
fi
log_info "Ingress port: ${INGRESS_PORT}"

# Get the port assigned by Home Assistant for external access
ASSIGNED_PORT=$(get_addon_port ${INGRESS_PORT})
if [ -z "${ASSIGNED_PORT}" ]; then
    ASSIGNED_PORT="${INGRESS_PORT}"
fi

# Debug information
log_debug "Configuration loaded:"
log_debug "Log level: ${LOG_LEVEL}"
log_debug "Agent enabled: ${AGENT_ENABLED}"
log_debug "External access: ${EXTERNAL_ACCESS}"
log_debug "Assigned port: ${ASSIGNED_PORT}"

# Debug Docker socket access
log_debug "Checking Docker socket access..."
if [ -S /var/run/docker.sock ]; then
    log_debug "Docker socket exists"
else
    log_warning "Docker socket not found at /var/run/docker.sock"
fi

# Get ingress entry point from Home Assistant
INGRESS_ENTRY=$(get_ingress_entry)
log_info "Ingress entry point: '${INGRESS_ENTRY}'"

# Trim whitespace from INGRESS_ENTRY
INGRESS_ENTRY=$(echo "${INGRESS_ENTRY}" | xargs)

# Build Dozzle command
if [[ "${EXTERNAL_ACCESS}" = "true" ]]; then
    CMD="${DOZZLE_BIN} --addr 0.0.0.0:${ASSIGNED_PORT} --no-analytics"
    log_info "External access enabled on port ${ASSIGNED_PORT}"
else
    CMD="${DOZZLE_BIN} --addr 127.0.0.1:${INGRESS_PORT} --base ${INGRESS_ENTRY} --no-analytics"
    log_info "Only ingress access enabled"
fi

# Add log level if specified
if [ -n "${LOG_LEVEL}" ]; then
    CMD="${CMD} --level ${LOG_LEVEL}"
fi

# Enable agent mode if configured and supported
if [[ "${AGENT_ENABLED}" = "true" ]]; then
    if [[ "${AGENT_SUPPORTED}" = "true" ]]; then
        log_info "Agent mode enabled on port 7007"
        CMD="${CMD} --agent --agent-addr 0.0.0.0:7007"
    else
        log_warning "Agent mode is requested but not supported in this version of Dozzle (${DOZZLE_VERSION}). Ignoring agent configuration."
    fi
fi

# Debug final configuration
log_debug "Dozzle Configuration:"
log_debug "  - Ingress Port: ${INGRESS_PORT}"
[[ "${EXTERNAL_ACCESS}" = "true" ]] && log_debug "  - External Port: ${ASSIGNED_PORT}"
log_debug "  - Entry point: ${INGRESS_ENTRY}"
log_debug "  - Command: ${CMD}"

# Start Dozzle
log_info "Starting Dozzle..."
exec ${CMD}