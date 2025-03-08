#!/bin/sh
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Main script to run Dozzle
# ==============================================================================
set -e

# Define paths
DOZZLE_BIN="/usr/local/bin/dozzle"

# Use simple echo for logging
log_info() { echo "[INFO] $1"; }
log_warning() { echo "[WARNING] $1"; }
log_error() { echo "[ERROR] $1"; }
log_debug() { echo "[DEBUG] $1"; }

# Default configuration values
LOG_LEVEL="info"
AGENT_ENABLED="false"
EXTERNAL_ACCESS="true"
INGRESS_PORT="8080"
INGRESS_ENTRY="/"

# Try to load configuration from Home Assistant if possible
if command -v ha >/dev/null 2>&1; then
    # Use ha command if available
    LOG_LEVEL=$(ha addon options --raw-json | jq -r '.LogLevel // "info"')
    AGENT_ENABLED=$(ha addon options --raw-json | jq -r '.DozzleAgent // false')
    EXTERNAL_ACCESS=$(ha addon options --raw-json | jq -r '.ExternalAccess // true')
    
    # Try to get ingress information
    INGRESS_ENTRY=$(ha addon info --raw-json | jq -r '.ingress_url // "/"')
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

# Debug information
log_debug "Configuration loaded:"
log_debug "Log level: ${LOG_LEVEL}"
log_debug "Agent enabled: ${AGENT_ENABLED}"
log_debug "External access: ${EXTERNAL_ACCESS}"

# Debug Docker socket access
log_debug "Checking Docker socket access..."
if [ -S /var/run/docker.sock ]; then
    log_debug "Docker socket exists"
else
    log_warning "Docker socket not found at /var/run/docker.sock"
fi

log_info "Ingress entry point: '${INGRESS_ENTRY}'"

# Build Dozzle command
if [ "${EXTERNAL_ACCESS}" = "true" ]; then
    CMD="${DOZZLE_BIN} --addr 0.0.0.0:${INGRESS_PORT} --no-analytics"
    log_info "External access enabled on port ${INGRESS_PORT}"
else
    CMD="${DOZZLE_BIN} --addr 127.0.0.1:${INGRESS_PORT} --base ${INGRESS_ENTRY} --no-analytics"
    log_info "Only ingress access enabled"
fi

# Add log level if specified
if [ -n "${LOG_LEVEL}" ]; then
    CMD="${CMD} --level ${LOG_LEVEL}"
fi

# Enable agent mode if configured and supported
if [ "${AGENT_ENABLED}" = "true" ]; then
    if [ "${AGENT_SUPPORTED}" = "true" ]; then
        log_info "Agent mode enabled on port 7007"
        CMD="${CMD} --agent --agent-addr 0.0.0.0:7007"
    else
        log_warning "Agent mode is requested but not supported in this version of Dozzle (${DOZZLE_VERSION}). Ignoring agent configuration."
    fi
fi

# Debug final configuration
log_debug "Dozzle Configuration:"
log_debug "  - Ingress Port: ${INGRESS_PORT}"
[ "${EXTERNAL_ACCESS}" = "true" ] && log_debug "  - External Port: ${INGRESS_PORT}"
log_debug "  - Entry point: ${INGRESS_ENTRY}"
log_debug "  - Command: ${CMD}"

# Start Dozzle
log_info "Starting Dozzle..."
exec ${CMD}