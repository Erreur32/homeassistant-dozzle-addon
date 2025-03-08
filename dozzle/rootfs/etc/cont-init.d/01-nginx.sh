#!/bin/bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Prepares the environment for nginx
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

echo "$(date '+%Y-%m-%d %H:%M:%S') Preparing environment for nginx..."

# Create required directories
mkdir -p /var/log/nginx
mkdir -p /var/lib/nginx/body
mkdir -p /etc/nginx/includes

# Remove any default nginx configuration that might be causing conflicts
rm -f /etc/nginx/conf.d/default.conf
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
rm -f /etc/nginx/http.d/default.conf
rm -f /etc/nginx/servers/ingress.conf

# Check if nginx is installed
if command -v nginx >/dev/null 2>&1; then
    NGINX_VERSION=$(nginx -v 2>&1 | sed 's/nginx version: nginx\///')
    echo "$(date '+%Y-%m-%d %H:%M:%S') Nginx version: ${NGINX_VERSION}"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Nginx is not installed"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Environment preparation for nginx completed" 