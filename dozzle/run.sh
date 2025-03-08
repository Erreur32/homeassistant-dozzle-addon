#!/bin/sh
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Main script to run Dozzle
# ==============================================================================
set -e

# Define paths
DOZZLE_BIN="/usr/local/bin/dozzle"
DOCKER_SOCKET="/var/run/docker.sock"

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Default configuration values
LOG_LEVEL="info"
AGENT_ENABLED="false"
EXTERNAL_ACCESS="true"
INGRESS_PORT="8080"
INGRESS_ENTRY="/"

# Try to load configuration from Home Assistant if possible
if command -v ha >/dev/null 2>&1; then
    # Use ha command if available
    LOG_LEVEL=$(ha addon options --raw-json | jq -r '.LogLevel // "info"' 2>/dev/null || echo "info")
    AGENT_ENABLED=$(ha addon options --raw-json | jq -r '.DozzleAgent // false' 2>/dev/null || echo "false")
    EXTERNAL_ACCESS=$(ha addon options --raw-json | jq -r '.ExternalAccess // true' 2>/dev/null || echo "true")
    
    # Try to get ingress information
    INGRESS_ENTRY=$(ha addon info --raw-json | jq -r '.ingress_url // "/"' 2>/dev/null || echo "/")
fi

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

# Function to print a line of dashes
print_line() {
    echo -e "${CYAN}-----------------------------------------------------------${NC}"
}

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

# Get system information
SYSTEM_INFO="Home Assistant"
ARCH=$(uname -m || echo "Unknown")
HA_VERSION="Latest"
SUPERVISOR_VERSION="Latest"
ADDON_VERSION="0.1.51"

# Try to get more detailed system information if possible
if [ -f /etc/os-release ]; then
    SYSTEM_INFO=$(grep -oP '(?<=PRETTY_NAME=")[^"]+' /etc/os-release || echo "Home Assistant")
fi

# Try to get Home Assistant version from environment variables
if [ -n "${SUPERVISOR_VERSION}" ]; then
    SUPERVISOR_VERSION="${SUPERVISOR_VERSION}"
fi
if [ -n "${HASSIO_VERSION}" ]; then
    HA_VERSION="${HASSIO_VERSION}"
fi

# Try to get addon version from environment or config
if [ -f /data/options.json ]; then
    ADDON_VERSION=$(jq -r '.version // "0.1.51"' /data/options.json 2>/dev/null || echo "0.1.51")
fi

# Try to get more detailed information using ha command if available
if command -v ha >/dev/null 2>&1; then
    # Try multiple approaches to get system info
    SYSTEM_INFO_TMP=$(ha supervisor info --raw-json 2>/dev/null | jq -r '.operating_system // ""' 2>/dev/null)
    if [ -n "${SYSTEM_INFO_TMP}" ] && [ "${SYSTEM_INFO_TMP}" != "null" ]; then
        SYSTEM_INFO="${SYSTEM_INFO_TMP}"
    fi
    
    ARCH_TMP=$(ha supervisor info --raw-json 2>/dev/null | jq -r '.arch // ""' 2>/dev/null)
    if [ -n "${ARCH_TMP}" ] && [ "${ARCH_TMP}" != "null" ]; then
        ARCH="${ARCH_TMP}"
    fi
    
    HA_VERSION_TMP=$(ha core info --raw-json 2>/dev/null | jq -r '.version // ""' 2>/dev/null)
    if [ -n "${HA_VERSION_TMP}" ] && [ "${HA_VERSION_TMP}" != "null" ]; then
        HA_VERSION="${HA_VERSION_TMP}"
    fi
    
    SUPERVISOR_VERSION_TMP=$(ha supervisor info --raw-json 2>/dev/null | jq -r '.version // ""' 2>/dev/null)
    if [ -n "${SUPERVISOR_VERSION_TMP}" ] && [ "${SUPERVISOR_VERSION_TMP}" != "null" ]; then
        SUPERVISOR_VERSION="${SUPERVISOR_VERSION_TMP}"
    fi
    
    ADDON_VERSION_TMP=$(ha addon info dozzle --raw-json 2>/dev/null | jq -r '.version // ""' 2>/dev/null)
    if [ -n "${ADDON_VERSION_TMP}" ] && [ "${ADDON_VERSION_TMP}" != "null" ]; then
        ADDON_VERSION="${ADDON_VERSION_TMP}"
    fi
fi

# Print header (always shown regardless of log level)
print_line
echo -e "${WHITE} Add-on: Dozzle - Docker Log Viewer${NC}"
echo -e "${WHITE} Real-time log viewer for Docker containers in Home Assistant${NC}"
print_line
echo -e "${WHITE} Add-on version: ${ADDON_VERSION}${NC}"
echo -e "${WHITE} Dozzle version: ${DOZZLE_VERSION}${NC}"
echo -e "${WHITE} System: ${SYSTEM_INFO} (${ARCH})${NC}"
echo -e "${WHITE} Home Assistant Core: ${HA_VERSION}${NC}"
echo -e "${WHITE} Home Assistant Supervisor: ${SUPERVISOR_VERSION}${NC}"
print_line
echo -e "${WHITE} Configuration:${NC}"
echo -e "${WHITE} - Log Level: ${LOG_LEVEL}${NC}"
echo -e "${WHITE} - External Access: ${EXTERNAL_ACCESS}${NC}"
echo -e "${WHITE} - Agent Mode: ${AGENT_ENABLED}${NC}"
echo -e "${WHITE} - Ingress Port: ${INGRESS_PORT}${NC}"
print_line
echo -e "${WHITE} Please share the above information when looking for help${NC}"
echo -e "${WHITE} or support in GitHub, forums or the Discord chat.${NC}"
print_line
echo ""

log_info "Dozzle version: ${DOZZLE_VERSION}"

# Wait for Docker socket to be available
MAX_RETRIES=30
RETRY_COUNT=0
log_info "Checking Docker socket access..."
while [ ! -S "${DOCKER_SOCKET}" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    log_warning "Docker socket not found at ${DOCKER_SOCKET}, retrying in 2 seconds (${RETRY_COUNT}/${MAX_RETRIES})..."
    sleep 2
done

if [ ! -S "${DOCKER_SOCKET}" ]; then
    log_error "Docker socket not found at ${DOCKER_SOCKET} after ${MAX_RETRIES} retries. Exiting."
    log_error "Please make sure Docker is running and the socket is accessible."
    log_error "You may need to add the Docker socket to the addon configuration."
    exit 1
else
    log_info "Docker socket found at ${DOCKER_SOCKET}"
    
    # Try multiple approaches to fix permissions for Docker socket
    if [ -w "${DOCKER_SOCKET}" ]; then
        log_info "Docker socket is already writable."
    else
        # Try to fix permissions using chmod
        if chmod 666 "${DOCKER_SOCKET}" 2>/dev/null; then
            log_info "Docker socket permissions set successfully with chmod."
        else
            # Try to fix permissions using setfacl if available
            if command -v setfacl >/dev/null 2>&1; then
                if setfacl -m u:$(id -u):rw "${DOCKER_SOCKET}" 2>/dev/null; then
                    log_info "Docker socket permissions set successfully with setfacl."
                else
                    log_warning "Failed to set permissions for Docker socket with setfacl."
                    log_warning "This may cause issues with Dozzle."
                fi
            else
                log_warning "Failed to set permissions for Docker socket with chmod."
                log_warning "This may cause issues with Dozzle."
                log_warning "You may need to run the addon with additional privileges."
            fi
        fi
    fi
fi

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
log_debug "Log level: ${LOG_LEVEL} (${CURRENT_LOG_LEVEL})"
log_debug "Agent enabled: ${AGENT_ENABLED}"
log_debug "External access: ${EXTERNAL_ACCESS}"

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