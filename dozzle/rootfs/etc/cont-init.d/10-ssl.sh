#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Dozzle
# ==============================================================================

# ==============================================================================
# SSL LOGIC
# ------------------------------------------------------------------------------
main() {
    local ssl
    local certfile
    local keyfile
    local password

    # Load config values with defaults
    ssl=$(bashio::config 'ssl' false)
    certfile=$(bashio::config 'certfile' 'fullchain.pem')
    keyfile=$(bashio::config 'keyfile' 'privkey.pem')
    password=$(bashio::config 'password' 'homeassistant')

    # Check if SSL is enabled
    if [ "$ssl" = true ]; then
        bashio::log.info "SSL is enabled"
        
        # Check if certificates exist
        if [ ! -f "/ssl/${certfile}" ] || [ ! -f "/ssl/${keyfile}" ]; then
            bashio::log.info "Generating SSL certificates..."
            
            # Create SSL directory if it doesn't exist
            mkdir -p /ssl
            
            # Generate self-signed certificate
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout "/ssl/${keyfile}" \
                -out "/ssl/${certfile}" \
                -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
                -passin "pass:${password}" \
                -passout "pass:${password}"
            
            bashio::log.info "SSL certificates generated successfully"
        else
            bashio::log.info "Using existing SSL certificates"
        fi
    else
        bashio::log.info "SSL is disabled"
    fi
}

# ==============================================================================
# EXECUTE LOGIC
# ------------------------------------------------------------------------------
main "$@" 