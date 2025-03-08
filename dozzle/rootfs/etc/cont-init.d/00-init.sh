#!/bin/sh
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Minimal initialization
# ==============================================================================

# Define paths
DOZZLE_BIN="/usr/local/bin/dozzle"

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