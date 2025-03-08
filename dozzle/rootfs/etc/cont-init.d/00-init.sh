#!/bin/bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Initialization script
# ==============================================================================

# Define paths
DOCKER_SOCKET="/var/run/docker.sock"
DOZZLE_BIN="/usr/local/bin/dozzle"
RUN_SCRIPT="/run.sh"

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Simple logging functions
log_info() {
    echo -e "${GREEN}[INFO] $(date '+%Y-%m-%d %H:%M:%S') $1${RESET}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $(date '+%Y-%m-%d %H:%M:%S') $1${RESET}"
}

log_error() {
    echo -e "${RED}[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1${RESET}"
}

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Docker socket exists
if [ ! -e "${DOCKER_SOCKET}" ]; then
    log_error "Docker socket not found at ${DOCKER_SOCKET}"
    log_error "Please make sure Docker is running and the socket is accessible"
    exit 1
fi

# Check if Docker socket is readable
if [ ! -r "${DOCKER_SOCKET}" ]; then
    log_warning "Docker socket is not readable, attempting to fix permissions"
    
    # Try to fix permissions with chmod
    if chmod 666 "${DOCKER_SOCKET}" 2>/dev/null; then
        log_info "Successfully fixed Docker socket permissions with chmod"
    else
        # Try to fix permissions with setfacl if available
        if command_exists setfacl; then
            if setfacl -m u:root:rw "${DOCKER_SOCKET}" 2>/dev/null; then
                log_info "Successfully fixed Docker socket permissions with setfacl"
            else
                log_warning "Failed to fix Docker socket permissions with setfacl"
            fi
        else
            log_warning "Failed to fix Docker socket permissions with chmod"
        fi
    fi
fi

# Check if Docker socket is writable
if [ ! -w "${DOCKER_SOCKET}" ]; then
    log_warning "Docker socket is still not writable after permission fixes"
    log_warning "This may cause issues with Dozzle"
else
    log_info "Docker socket is writable"
fi

# Check if Dozzle executable exists
if [ ! -f "${DOZZLE_BIN}" ]; then
    log_error "Dozzle executable not found at ${DOZZLE_BIN}"
    exit 1
fi

# Check if Dozzle executable is executable
if [ ! -x "${DOZZLE_BIN}" ]; then
    log_warning "Dozzle executable is not executable, attempting to fix permissions"
    
    if chmod +x "${DOZZLE_BIN}" 2>/dev/null; then
        log_info "Successfully fixed Dozzle executable permissions"
    else
        log_error "Failed to fix Dozzle executable permissions"
        exit 1
    fi
fi

# Get Dozzle version
DOZZLE_VERSION=$(${DOZZLE_BIN} --version 2>/dev/null | sed 's/dozzle version //' || echo "Unknown")
log_info "Dozzle version: ${DOZZLE_VERSION}"

# Check if run script exists
if [ ! -f "${RUN_SCRIPT}" ]; then
    log_error "Run script not found at ${RUN_SCRIPT}"
    exit 1
fi

# Check if run script is executable
if [ ! -x "${RUN_SCRIPT}" ]; then
    log_warning "Run script is not executable, attempting to fix permissions"
    
    if chmod +x "${RUN_SCRIPT}" 2>/dev/null; then
        log_info "Successfully fixed run script permissions"
    else
        log_error "Failed to fix run script permissions"
        exit 1
    fi
fi

# Create necessary directories
mkdir -p /var/run/s6/container_environment

# Set environment variables
echo "DOCKER_HOST=unix:///var/run/docker.sock" > /var/run/s6/container_environment/DOCKER_HOST

log_info "Initialization completed successfully"
exit 0 