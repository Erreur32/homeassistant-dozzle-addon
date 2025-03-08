#!/bin/sh
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Minimal initialization
# ==============================================================================

# Define paths
DOZZLE_BIN="/usr/local/bin/dozzle"
DOCKER_SOCKET="/var/run/docker.sock"

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default log level (can be overridden by environment variable)
LOG_LEVEL="${LOG_LEVEL:-info}"

# Define log level values
LOG_LEVEL_DEBUG=3
LOG_LEVEL_INFO=2
LOG_LEVEL_WARNING=1
LOG_LEVEL_ERROR=0

# Set current log level based on configuration
CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO
case "${LOG_LEVEL}" in
    "debug")
        CURRENT_LOG_LEVEL=$LOG_LEVEL_DEBUG
        ;;
    "info")
        CURRENT_LOG_LEVEL=$LOG_LEVEL_INFO
        ;;
    "error")
        CURRENT_LOG_LEVEL=$LOG_LEVEL_ERROR
        ;;
esac

# Use colored echo for logging with timestamp and level filtering
log_debug() { 
    if [ $CURRENT_LOG_LEVEL -ge $LOG_LEVEL_DEBUG ]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo -e "${BLUE}[DEBUG]${NC} ${BLUE}${timestamp}${NC} $1"
    fi
}

log_info() { 
    if [ $CURRENT_LOG_LEVEL -ge $LOG_LEVEL_INFO ]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo -e "${GREEN}[INFO]${NC} ${BLUE}${timestamp}${NC} $1"
    fi
}

log_warning() { 
    if [ $CURRENT_LOG_LEVEL -ge $LOG_LEVEL_WARNING ]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo -e "${YELLOW}[WARNING]${NC} ${BLUE}${timestamp}${NC} $1"
    fi
}

log_error() { 
    if [ $CURRENT_LOG_LEVEL -ge $LOG_LEVEL_ERROR ]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo -e "${RED}[ERROR]${NC} ${BLUE}${timestamp}${NC} $1"
    fi
}

log_debug "Log level set to: ${LOG_LEVEL} (${CURRENT_LOG_LEVEL})"
log_info "Initializing Dozzle..."

# Check Docker socket access
if [ ! -S "${DOCKER_SOCKET}" ]; then
    log_warning "Docker socket is not accessible at ${DOCKER_SOCKET}!"
    log_warning "Dozzle will wait for it to become available at startup."
    log_warning "Make sure Docker is running and the socket is accessible."
    log_warning "You may need to add the Docker socket to the addon configuration."
else
    log_info "Docker socket found at ${DOCKER_SOCKET}"
    
    # Try to fix permissions for Docker socket
    if ! chmod 666 "${DOCKER_SOCKET}" 2>/dev/null; then
        log_warning "Failed to set permissions for Docker socket. This may cause issues."
        log_warning "You may need to run the addon with additional privileges."
    else
        log_info "Docker socket permissions set successfully."
    fi
    
    # Try to check Docker connectivity
    if command -v docker >/dev/null 2>&1; then
        if ! docker info >/dev/null 2>&1; then
            log_warning "Docker is installed but not responding. This may cause issues."
        else
            log_info "Docker is responding correctly."
        fi
    fi
fi

# Check Dozzle executable
if [ ! -x "${DOZZLE_BIN}" ]; then
    log_error "Dozzle executable not found or not executable!"
    exit 1
else
    log_info "Dozzle executable found at ${DOZZLE_BIN}"
    
    # Try to get Dozzle version
    DOZZLE_VERSION=$(${DOZZLE_BIN} --version 2>&1 || echo "unknown")
    log_info "Dozzle version: ${DOZZLE_VERSION}"
fi

# Check run.sh script
if [ ! -x /run.sh ]; then
    log_warning "run.sh script not found or not executable!"
    if ! chmod +x /run.sh 2>/dev/null; then
        log_error "Failed to make run.sh executable"
    else
        log_info "run.sh script permissions set successfully."
    fi
else
    log_info "run.sh script is executable."
fi

log_info "Initialization completed." 