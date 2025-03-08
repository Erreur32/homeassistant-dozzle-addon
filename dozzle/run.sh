#!/bin/bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# ==============================================================================

# Define paths
DOCKER_SOCKET="/var/run/docker.sock"
LOCK_FILE="/tmp/dozzle.lock"
CONFIG_PATH="/data/options.json"

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Define log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARNING=2
LOG_LEVEL_ERROR=3

# Simple logging functions
log_debug() {
    echo -e "${CYAN}[DEBUG] $(date '+%Y-%m-%d %H:%M:%S') $1${RESET}"
}

log_info() {
    echo -e "${GREEN}[INFO] $(date '+%Y-%m-%d %H:%M:%S') $1${RESET}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING] $(date '+%Y-%m-%d %H:%M:%S') $1${RESET}"
}

log_error() {
    echo -e "${RED}[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1${RESET}"
}

# Function to get system information
get_system_info() {
    # Try to get system information using ha command
    if command -v ha >/dev/null 2>&1; then
        HOSTNAME=$(ha host info --raw-json | jq -r '.data.hostname // "Unknown"')
        OS=$(ha host info --raw-json | jq -r '.data.operating_system // "Unknown"')
        VERSION=$(ha core info --raw-json | jq -r '.data.version // "Unknown"')
    else
        # Fallback to system commands
        HOSTNAME=$(hostname 2>/dev/null || echo "Unknown")
        if [ -f /etc/os-release ]; then
            # Use sed instead of grep for better compatibility
            OS=$(sed -n 's/^PRETTY_NAME="\(.*\)"$/\1/p' /etc/os-release 2>/dev/null || echo "Unknown")
        else
            OS="Unknown"
        fi
        VERSION="Unknown"
    fi

    # Get Dozzle version
    DOZZLE_VERSION=$(/usr/local/bin/dozzle --version 2>/dev/null | sed 's/dozzle version //' || echo "Unknown")

    echo -e "${BLUE}=======================================================${RESET}"
    echo -e "${BLUE}= Dozzle Add-on for Home Assistant                   =${RESET}"
    echo -e "${BLUE}=======================================================${RESET}"
    echo -e "${BLUE}= Hostname: ${RESET}${HOSTNAME}"
    echo -e "${BLUE}= OS: ${RESET}${OS}"
    echo -e "${BLUE}= Home Assistant: ${RESET}${VERSION}"
    echo -e "${BLUE}= Dozzle: ${RESET}${DOZZLE_VERSION}"
    echo -e "${BLUE}=======================================================${RESET}"
}

# Function to check if Docker socket is available
check_docker_socket() {
    if [ ! -e "${DOCKER_SOCKET}" ]; then
        log_error "Docker socket not found at ${DOCKER_SOCKET}"
        return 1
    fi

    if [ ! -r "${DOCKER_SOCKET}" ]; then
        log_error "Docker socket is not readable"
        return 1
    fi

    if [ ! -w "${DOCKER_SOCKET}" ]; then
        log_warning "Docker socket is not writable, attempting to fix permissions"
        
        # Try to fix permissions with chmod
        if chmod 666 "${DOCKER_SOCKET}" 2>/dev/null; then
            log_info "Successfully fixed Docker socket permissions with chmod"
            return 0
        fi
        
        # Try to fix permissions with setfacl if available
        if command -v setfacl >/dev/null 2>&1; then
            if setfacl -m u:root:rw "${DOCKER_SOCKET}" 2>/dev/null; then
                log_info "Successfully fixed Docker socket permissions with setfacl"
                return 0
            fi
        fi
        
        log_error "Failed to fix Docker socket permissions"
        return 1
    fi

    return 0
}

# Function to check if Docker is responding
check_docker_connectivity() {
    if ! curl -s --unix-socket "${DOCKER_SOCKET}" http://localhost/info >/dev/null 2>&1; then
        log_error "Docker is not responding"
        return 1
    fi
    
    log_info "Docker is responding correctly"
    return 0
}

# Function to check if a command supports an option
check_command_option() {
    local cmd="$1"
    local option="$2"
    
    # Use sed instead of grep for better compatibility
    if $cmd --help 2>&1 | sed -n "/$option/p" | wc -l > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Main function
main() {
    # Display system information
    get_system_info

    # Check for lock file to prevent multiple instances
    if [ -f "${LOCK_FILE}" ]; then
        log_warning "Lock file exists, another instance may be running"
        rm -f "${LOCK_FILE}"
    fi
    
    # Create lock file
    touch "${LOCK_FILE}"
    
    # Check Docker socket with retries
    local max_retries=5
    local retry_count=0
    local retry_delay=5
    
    while [ ${retry_count} -lt ${max_retries} ]; do
        log_info "Checking Docker socket (attempt $((retry_count + 1))/${max_retries})"
        
        if check_docker_socket && check_docker_connectivity; then
            log_info "Docker socket is available and responding"
            break
        fi
        
        retry_count=$((retry_count + 1))
        
        if [ ${retry_count} -lt ${max_retries} ]; then
            log_warning "Retrying in ${retry_delay} seconds..."
            sleep ${retry_delay}
        else
            log_error "Maximum retries reached, unable to connect to Docker"
            rm -f "${LOCK_FILE}"
            exit 1
        fi
    done
    
    # Get configuration values
    LOG_LEVEL=$(jq -r '.log_level // "info"' ${CONFIG_PATH})
    EXTERNAL_ACCESS=$(jq -r '.external_access // "false"' ${CONFIG_PATH})
    AGENT_MODE=$(jq -r '.agent_mode // "false"' ${CONFIG_PATH})
    
    # Set Dozzle options
    if [ "${EXTERNAL_ACCESS}" = "true" ]; then
        # Use 0.0.0.0 to allow external access
        log_info "External access enabled"
        DOZZLE_OPTS="--addr 0.0.0.0:8080 --base / --level ${LOG_LEVEL}"
    else
        # Use 127.0.0.1 for internal access only (ingress)
        log_info "External access disabled, using ingress only"
        DOZZLE_OPTS="--addr 127.0.0.1:8080 --base / --level ${LOG_LEVEL}"
    fi
    
    # Add agent mode if enabled
    if [ "${AGENT_MODE}" = "true" ]; then
        DOZZLE_OPTS="${DOZZLE_OPTS} --agent"
        log_info "Agent mode enabled"
    fi
    
    log_info "Starting Dozzle with options: ${DOZZLE_OPTS}"
    
    # Remove lock file
    rm -f "${LOCK_FILE}"
    
    # Start Dozzle
    exec /usr/local/bin/dozzle ${DOZZLE_OPTS}
}

# Run main function
main "$@"