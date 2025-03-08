#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Minimal initialization
# ==============================================================================

# Define paths
DOZZLE_BIN="/usr/local/bin/dozzle"

# Use simple echo for logging
log_info() { echo "[INFO] $1"; }
log_warning() { echo "[WARNING] $1"; }
log_error() { echo "[ERROR] $1"; }

log_info "Initializing Dozzle..."

# Check Docker socket access
if [ ! -S /var/run/docker.sock ]; then
    log_warning "Docker socket is not accessible!"
fi

# Check Dozzle executable
if [ ! -x "${DOZZLE_BIN}" ]; then
    log_error "Dozzle executable not found or not executable!"
    exit 1
fi

# Check run.sh script
if [ ! -x /run.sh ]; then
    log_warning "run.sh script not found or not executable!"
    chmod +x /run.sh 2>/dev/null || log_error "Failed to make run.sh executable"
fi

log_info "Initialization completed." 