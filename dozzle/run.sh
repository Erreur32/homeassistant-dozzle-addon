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
    echo -e "${WHITE} - Log Level: ${LOG_LEVEL}${RESET}"
    echo -e "${WHITE} - External Access: ${EXTERNAL_ACCESS}${RESET}"
    echo -e "${WHITE} - Agent Mode: ${AGENT_MODE}${RESET}"
    echo -e "${WHITE} - Ingress Port: 8080${RESET}"
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
    cat "${CONFIG_PATH}" || log_warning "Failed to read configuration file"
    
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

# Function to setup nginx for ingress
setup_nginx() {
    # Create nginx config directory if it doesn't exist
    mkdir -p /etc/nginx/includes
    
    # Create server_params.conf if it doesn't exist
    if [ ! -f "/etc/nginx/includes/server_params.conf" ]; then
        log_info "Creating nginx server parameters configuration"
        cat > /etc/nginx/includes/server_params.conf << 'EOF'
# Basic server parameters
server_name _;
root /dev/null;

add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header X-Robots-Tag none;

client_max_body_size 64M;

# Disable logging for privacy
access_log off;
error_log /dev/null;
EOF
    fi
    
    # Create upstream.conf for Dozzle
    log_info "Creating nginx upstream configuration for Dozzle"
    cat > /etc/nginx/includes/upstream.conf << EOF
upstream dozzle {
    server 127.0.0.1:8080;
}
EOF
    
    log_info "Nginx configuration for ingress completed"
}

# Main function
main() {
    # Read configuration
    read_config
    
    # Setup nginx for ingress
    setup_nginx
    
    # Display system information with configuration values at the beginning
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
        
        if check_docker_socket; then
            log_info "Docker socket is available"
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
    
    # Check if agent mode is supported
    AGENT_SUPPORTED=false
    if /usr/local/bin/dozzle --help 2>&1 | sed -n '/--agent/p' | wc -l > /dev/null 2>&1; then
        AGENT_SUPPORTED=true
        log_info "Agent mode is supported in this version of Dozzle"
    else
        log_warning "Agent mode is NOT supported in this version of Dozzle (${DOZZLE_VERSION})"
    fi
    
    # Set Dozzle options
    DOZZLE_OPTS="--level ${LOG_LEVEL}"
    
    # Configure address based on external access setting
    # Always listen on all interfaces (0.0.0.0) for ingress to work
    # External access is controlled by Home Assistant port mapping
    log_info "Configuring Dozzle to listen on all interfaces (0.0.0.0:8080)"
    DOZZLE_OPTS="${DOZZLE_OPTS} --addr 0.0.0.0:8080"
    
    if [ "${EXTERNAL_ACCESS}" = "true" ]; then
        log_info "External access is enabled"
    else
        log_info "External access is disabled (only accessible via ingress)"
    fi
    
    # Add base path
    DOZZLE_OPTS="${DOZZLE_OPTS} --base /"
    
    # Add agent mode if enabled and supported
    if [ "${AGENT_MODE}" = "true" ]; then
        if [ "${AGENT_SUPPORTED}" = "true" ]; then
            log_info "Agent mode enabled on port 7007"
            DOZZLE_OPTS="${DOZZLE_OPTS} --agent --agent-addr 0.0.0.0:7007"
        else
            log_warning "Agent mode is requested but not supported in this version of Dozzle (${DOZZLE_VERSION}). Ignoring agent configuration."
        fi
    fi
    
    log_info "Starting Dozzle with options: ${DOZZLE_OPTS}"
    
    # Remove lock file
    rm -f "${LOCK_FILE}"
    
    # Start Dozzle
    exec /usr/local/bin/dozzle ${DOZZLE_OPTS}
}

# Run main function
main "$@"