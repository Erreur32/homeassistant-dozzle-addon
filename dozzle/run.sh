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
    
    # Check nginx status
    if is_nginx_working; then
        NGINX_STATUS="${GREEN}Running${RESET}"
        NGINX_PORT="${GREEN}Listening on 8099${RESET}"
    else
        if pgrep -x "nginx" >/dev/null; then
            NGINX_STATUS="${YELLOW}Running${RESET}"
            NGINX_PORT="${RED}Not responding on 8099${RESET}"
        else
            NGINX_STATUS="${RED}Not Running${RESET}"
            NGINX_PORT="${RED}Port 8099 unavailable${RESET}"
        fi
    fi
    
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
    echo -e "${WHITE} - Ingress Port: 8099${RESET}"
    echo -e "${WHITE} - Nginx Status: ${NGINX_STATUS} - ${NGINX_PORT}${RESET}"
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

# Function to check if nginx is running and responding
is_nginx_working() {
    local max_wait=10  # Attendre maximum 10 secondes
    local wait_count=0
    
    # 1. Attendre et vérifier le master process nginx
    while [ $wait_count -lt $max_wait ]; do
        if pgrep -f "nginx: master process" > /dev/null; then
            log_debug "✅ Master process nginx trouvé"
            break
        fi
        wait_count=$((wait_count + 1))
        if [ $wait_count -eq 1 ]; then
            log_debug "⏳ Attente du démarrage du master process nginx..."
        fi
        sleep 1
    done
    
    if [ $wait_count -eq $max_wait ]; then
        log_warning "❌ Master process nginx non trouvé après ${max_wait} secondes"
        # Afficher les processus pour le debug
        log_debug "🔍 Processus actuels :"
        ps aux | grep -E "(nginx|s6-supervise)" | grep -v grep || true
        return 1
    fi
    
    # Récupérer le PID du master process
    NGINX_PID=$(pgrep -f "nginx: master process")
    log_debug "✅ Master process nginx trouvé (PID: ${NGINX_PID})"
    
    # 2. Vérifier si le port 8099 est en écoute
    if ! netstat -tuln | grep -q ":8099 "; then
        log_warning "❌ Port 8099 non trouvé dans netstat"
        log_debug "🔍 Ports en écoute :"
        netstat -tuln | grep "LISTEN" | grep -v "127.0.0.11" || true
        return 1
    fi
    log_debug "✅ Port 8099 en écoute"
    
    # 3. Vérifier la configuration nginx
    if [ -f "/etc/nginx/nginx.conf" ]; then
        if ! nginx -t &>/dev/null; then
            log_warning "❌ Configuration nginx invalide"
            return 1
        fi
        log_debug "✅ Configuration nginx valide"
    else
        log_warning "❌ Fichier de configuration nginx non trouvé"
        return 1
    fi
    
    # 4. Vérifier si upstream.conf existe et contient la bonne configuration
    if [ ! -f "/etc/nginx/includes/upstream.conf" ]; then
        log_warning "❌ Fichier upstream.conf manquant"
        return 1
    fi
    
    if ! grep -q "server 127.0.0.1:8080" "/etc/nginx/includes/upstream.conf"; then
        log_warning "❌ Configuration upstream incorrecte"
        return 1
    fi
    log_debug "✅ Configuration upstream correcte"
    
    # 5. Tester l'accès à Dozzle via nginx
    local response
    response=$(wget -qO- http://127.0.0.1:8099 2>/dev/null)
    if [ $? -ne 0 ]; then
        log_warning "❌ Impossible d'accéder à Dozzle via nginx"
        return 1
    fi
    
    if ! echo "$response" | grep -q "Dozzle"; then
        log_warning "❌ La réponse ne contient pas 'Dozzle'"
        return 1
    fi
    log_debug "✅ Dozzle accessible via nginx"
    
    return 0
}

# Function to check nginx status
check_nginx_status() {
    log_info "🔍 Vérification complète de nginx..."
    
    if is_nginx_working; then
        log_info "✅ Nginx fonctionne parfaitement :"
        log_info "  ✓ Master process en cours d'exécution (PID: $(pgrep -f 'nginx: master process'))"
        log_info "  ✓ Port 8099 en écoute"
        log_info "  ✓ Configuration valide"
        log_info "  ✓ Upstream configuré"
        log_info "  ✓ Dozzle accessible"
        return 0
    else
        log_warning "⚠️ Problèmes détectés avec nginx"
        
        # Afficher les processus nginx en cours
        log_debug "🔍 Processus nginx :"
        ps aux | grep -E "(nginx|s6-supervise)" | grep -v grep || true
        
        # Afficher les ports en écoute
        log_debug "🔍 Ports en écoute :"
        netstat -tuln | grep "LISTEN" | grep -v "127.0.0.11" || true
        
        return 1
    fi
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

# Function to setup nginx for ingress
setup_nginx() {
    # Cette fonction est maintenant simplifiée pour éviter les conflits
    # avec le script de démarrage de nginx géré par S6
    
    # Créer le répertoire includes si nécessaire
    mkdir -p /etc/nginx/includes
    
    # Créer upstream.conf pour Dozzle (sera inclus par nginx.conf)
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
    
    # Set Dozzle options avant le démarrage des services
    DOZZLE_OPTS="--level ${LOG_LEVEL}"
    
    # Configure address based on external access setting
    if [ "${EXTERNAL_ACCESS}" = "true" ]; then
        log_info "External access is enabled (port 8080 will be exposed)"
        DOZZLE_OPTS="${DOZZLE_OPTS} --addr 0.0.0.0:8080"
    else
        log_info "External access is disabled (port 8080 will not be accessible from outside)"
        DOZZLE_OPTS="${DOZZLE_OPTS} --addr 127.0.0.1:8080"
    fi
    
    # Add base path
    DOZZLE_OPTS="${DOZZLE_OPTS} --base /"
    
    # Add agent mode if enabled and supported
    if [ "${AGENT_MODE}" = "true" ]; then
        if check_command_option "/usr/local/bin/dozzle" "--agent"; then
            log_info "Agent mode enabled on port 7007"
            DOZZLE_OPTS="${DOZZLE_OPTS} --agent --agent-addr 0.0.0.0:7007"
        else
            log_warning "Agent mode is requested but not supported in this version"
        fi
    fi
    
    # Démarrer Dozzle en arrière-plan
    log_info "Starting Dozzle with options: ${DOZZLE_OPTS}"
    /usr/local/bin/dozzle ${DOZZLE_OPTS} &
    DOZZLE_PID=$!
    
    # Attendre que Dozzle soit prêt (max 10 secondes)
    log_info "Waiting for Dozzle to be ready..."
    max_wait=10
    wait_count=0
    while [ $wait_count -lt $max_wait ]; do
        if curl -s http://127.0.0.1:8080 >/dev/null 2>&1; then
            log_info "✅ Dozzle is ready"
            break
        fi
        wait_count=$((wait_count + 1))
        sleep 1
    done
    
    if [ $wait_count -eq $max_wait ]; then
        log_error "❌ Dozzle failed to start within ${max_wait} seconds"
        kill $DOZZLE_PID
        exit 1
    fi
    
    # Attendre que S6 démarre les services (5 secondes)
    log_info "Waiting for S6 services..."
    sleep 5
    
    # Display system information
    get_system_info
    
    # Check nginx status
    check_nginx_status
    
    # Remove lock file
    rm -f "${LOCK_FILE}"
    
    # Attendre que Dozzle se termine
    wait $DOZZLE_PID
}

# Run main function
main "$@"