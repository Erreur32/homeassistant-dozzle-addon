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
WHITE='\033[1;37m'
RESET='\033[0m'

# Define log levels
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARNING=2
LOG_LEVEL_ERROR=3

# Simple logging functions
log_debug() {
    # Ne pas afficher les messages DEBUG si le niveau de log est supérieur à DEBUG
    if [ "${LOG_LEVEL}" != "debug" ]; then
        return
    fi
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

# Function to print a line of dashes
print_line() {
    echo -e "${CYAN}-----------------------------------------------------------${RESET}"
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
    
    # Set colored status for External Access with symbols
    if [ "${EXTERNAL_ACCESS}" = "true" ]; then
        EXTERNAL_ACCESS_STATUS="${GREEN}✓ ${EXTERNAL_ACCESS}${RESET}"
    else
        EXTERNAL_ACCESS_STATUS="${RED}✗ ${EXTERNAL_ACCESS}${RESET}"
    fi
    
    # Set colored status for Agent Mode with symbols
    if [ "${AGENT_MODE}" = "true" ]; then
        AGENT_MODE_STATUS="${GREEN}✓ ${AGENT_MODE}${RESET}"
    else
        AGENT_MODE_STATUS="${RED}✗ ${AGENT_MODE}${RESET}"
    fi
    
    # Set colored status for Log Level with symbols
    case "${LOG_LEVEL}" in
        "debug")
            LOG_LEVEL_STATUS="${YELLOW}⚠ ${LOG_LEVEL}${RESET}"
            ;;
        "info")
            LOG_LEVEL_STATUS="${GREEN}✓ ${LOG_LEVEL}${RESET}"
            ;;
        "error")
            LOG_LEVEL_STATUS="${RED}⚠ ${LOG_LEVEL}${RESET}"
            ;;
        *)
            LOG_LEVEL_STATUS="${WHITE}${LOG_LEVEL}${RESET}"
            ;;
    esac

    # Print header (always shown regardless of log level)
    print_line
    echo -e "${WHITE} Add-on: Dozzle - Docker Log Viewer${RESET}"
    echo -e "${WHITE} Real-time log viewer for Docker containers in Home Assistant${RESET}"
    print_line
    echo -e "${WHITE} Add-on version: 0.1.51${RESET}"
    echo -e "${WHITE} Dozzle version: ${DOZZLE_VERSION}${RESET}"
    echo -e "${WHITE} System: ${OS} ($(uname -m))${RESET}"
    echo -e "${WHITE} Home Assistant Core: ${VERSION}${RESET}"
    echo -e "${WHITE} Home Assistant Supervisor: Latest${RESET}"
    print_line
    echo -e "${WHITE} Configuration:${RESET}"
    echo -e "${WHITE} - Log Level: ${LOG_LEVEL_STATUS}${RESET}"
    echo -e "${WHITE} - External Access: ${EXTERNAL_ACCESS_STATUS}${RESET}"
    echo -e "${WHITE} - Agent Mode: ${AGENT_MODE_STATUS}${RESET}"
    print_line
    echo -e "${WHITE} Please share the above information when looking for help${RESET}"
    echo -e "${WHITE} or support in GitHub, forums or the Discord chat.${RESET}"
    print_line
    echo ""
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
    # Skip Docker connectivity check to avoid curl segmentation fault
    log_info "Skipping Docker connectivity check (to avoid curl segmentation fault)"
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

# Function to read configuration from options.json
read_config() {
    # Set default values first
    LOG_LEVEL="info"
    EXTERNAL_ACCESS="false"  # Default to false for external access
    AGENT_MODE="false"
    
    # Check if config file exists
    if [ ! -f "${CONFIG_PATH}" ]; then
        log_warning "Configuration file not found at ${CONFIG_PATH}, using defaults"
        return
    fi
    
    # Dump config file content for debugging
    log_info "Reading configuration from ${CONFIG_PATH}"
    #cat "${CONFIG_PATH}" || log_warning "Failed to read configuration file"
    
    # Read log_level using grep and sed to avoid jq segmentation faults
    LOG_LEVEL_TMP=$(grep -o '"log_level"[[:space:]]*:[[:space:]]*"[^"]*"' "${CONFIG_PATH}" 2>/dev/null | sed 's/"log_level"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
    if [ -n "${LOG_LEVEL_TMP}" ]; then
        LOG_LEVEL="${LOG_LEVEL_TMP}"
        log_info "Read log_level from config: ${LOG_LEVEL}"
    fi
    
    # Read external_access using grep and sed
    EXTERNAL_ACCESS_TMP=$(grep -o '"external_access"[[:space:]]*:[[:space:]]*[a-zA-Z]*' "${CONFIG_PATH}" 2>/dev/null | sed 's/"external_access"[[:space:]]*:[[:space:]]*\([a-zA-Z]*\)/\1/')
    if [ -n "${EXTERNAL_ACCESS_TMP}" ]; then
        # Convert to lowercase for comparison
        EXTERNAL_ACCESS_LOWER=$(echo "${EXTERNAL_ACCESS_TMP}" | tr '[:upper:]' '[:lower:]')
        
        if [ "${EXTERNAL_ACCESS_LOWER}" = "true" ]; then
            EXTERNAL_ACCESS="true"
        else
            EXTERNAL_ACCESS="false"
        fi
        log_info "Read external_access from config: ${EXTERNAL_ACCESS}"
    fi
    
    # Read agent_mode using grep and sed
    AGENT_MODE_TMP=$(grep -o '"agent_mode"[[:space:]]*:[[:space:]]*[a-zA-Z]*' "${CONFIG_PATH}" 2>/dev/null | sed 's/"agent_mode"[[:space:]]*:[[:space:]]*\([a-zA-Z]*\)/\1/')
    if [ -n "${AGENT_MODE_TMP}" ]; then
        # Convert to lowercase for comparison
        AGENT_MODE_LOWER=$(echo "${AGENT_MODE_TMP}" | tr '[:upper:]' '[:lower:]')
        
        if [ "${AGENT_MODE_LOWER}" = "true" ]; then
            AGENT_MODE="true"
        else
            AGENT_MODE="false"
        fi
        log_info "Read agent_mode from config: ${AGENT_MODE}"
    fi
    
    # Final log of configuration
    log_info "Final configuration:"
    log_info "- Log level: ${LOG_LEVEL}"
    log_info "- External access: ${EXTERNAL_ACCESS}"
    log_info "- Agent mode: ${AGENT_MODE}"
}

# Function to check if we're running in ingress mode
is_ingress() {
    if [ "${INGRESS_ENABLED}" = "true" ]; then
        return 0
    fi
    return 1
}

# Function to get the correct port based on ingress status
get_port() {
    if is_ingress; then
        echo "${INGRESS_PORT}"
    else
        echo "8080"
    fi
}

# Function to get the correct host based on ingress status
get_host() {
    if is_ingress; then
        echo "0.0.0.0"
    else
        echo "[HOST]"
    fi
}

# Function to get the correct base URL
get_base_url() {
    if is_ingress; then
        echo "http://${INGRESS_HOST}"
    else
        echo "http://[HOST]:[PORT:8080]"
    fi
}

# Main function
main() {
    # Read configuration
    read_config
    
    # Check for lock file to prevent multiple instances
    if [ -f "${LOCK_FILE}" ]; then
        log_warning "Lock file exists, another instance may be running"
        rm -f "${LOCK_FILE}"
    fi
    touch "${LOCK_FILE}"
    
    # Get system information
    get_system_info
    
    # Check Docker socket
    if ! check_docker_socket; then
        log_error "Failed to verify Docker socket"
        exit 1
    fi
    
    # Build Dozzle command
    DOZZLE_CMD="/usr/local/bin/dozzle"
    DOZZLE_OPTS="--socket ${DOCKER_SOCKET}"
    
    # Add port configuration
    PORT=$(get_port)
    DOZZLE_OPTS="${DOZZLE_OPTS} --port ${PORT}"
    
    # Add host configuration
    HOST=$(get_host)
    DOZZLE_OPTS="${DOZZLE_OPTS} --host ${HOST}"
    
    # Add log level if specified
    if [ -n "${LOG_LEVEL}" ]; then
        DOZZLE_OPTS="${DOZZLE_OPTS} --log-level ${LOG_LEVEL}"
    fi
    
    # Add agent mode if enabled
    if [ "${AGENT_MODE}" = "true" ]; then
        DOZZLE_OPTS="${DOZZLE_OPTS} --agent"
    fi
    
    # Start Dozzle with updated parameters
    log_info "Starting Dozzle with command: /usr/local/bin/dozzle --addr :8080 --base / --level ${LOG_LEVEL}"
    /usr/local/bin/dozzle --addr :8080 --base / --level ${LOG_LEVEL}
    
    # Remove lock file
    rm -f "${LOCK_FILE}"

    # Start Dozzle with updated parameters
    /usr/local/bin/dozzle --addr :8080 --base / --level ${LOG_LEVEL}
    
    # Attendre un peu que Dozzle démarre
    sleep 2
    
    # Vérifier nginx maintenant que Dozzle est démarré
    check_nginx_status
    
    # Si la vérification a échoué, on log une erreur mais on continue
    if [ "${NGINX_CHECK_OK}" = "false" ]; then
        log_warning "Nginx check failed but continuing..."
    fi
    
    # Attendre que Dozzle se termine
    wait
}

# Run main function
main