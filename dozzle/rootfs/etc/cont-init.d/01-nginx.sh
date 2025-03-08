#!/bin/bash
# ==============================================================================
# Home Assistant Add-on: Dozzle
# Configures nginx for ingress support
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

echo "$(date '+%Y-%m-%d %H:%M:%S') Configuring nginx for ingress support..."

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

# Create a minimal nginx configuration that only listens on port 8099
echo "$(date '+%Y-%m-%d %H:%M:%S') Creating nginx configuration..."
cat > /etc/nginx/nginx.conf << 'EOF'
worker_processes 1;
pid /var/run/nginx.pid;
error_log /dev/stdout info;
daemon off;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    proxy_read_timeout 1200;
    gzip on;
    gzip_disable "msie6";
    
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }
    
    # Ingress configuration - ONLY listen on port 8099
    server {
        listen 8099 default_server;
        
        server_name _;
        access_log /dev/stdout combined;
        
        client_max_body_size 64M;
        keepalive_timeout 65;
        
        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            
            proxy_redirect off;
            proxy_buffering off;
        }
    }
}
EOF

# Verify nginx configuration
echo "$(date '+%Y-%m-%d %H:%M:%S') Verifying nginx configuration..."
if nginx -t; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Nginx configuration is valid"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Nginx configuration is invalid"
    # Continue anyway, as we don't want to block the startup
fi

# Check if port 8099 is already in use
if netstat -tuln | grep -q ":8099 "; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') WARNING: Port 8099 is already in use"
    # Show which process is using the port
    echo "$(date '+%Y-%m-%d %H:%M:%S') Process using port 8099:"
    if command -v lsof >/dev/null 2>&1; then
        lsof -i :8099
    elif command -v fuser >/dev/null 2>&1; then
        fuser -n tcp 8099
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') Cannot determine which process is using port 8099 (lsof/fuser not available)"
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') Port 8099 is available for nginx"
fi

# Check if nginx is installed
if command -v nginx >/dev/null 2>&1; then
    NGINX_VERSION=$(nginx -v 2>&1 | sed 's/nginx version: nginx\///')
    echo "$(date '+%Y-%m-%d %H:%M:%S') Nginx version: ${NGINX_VERSION}"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Nginx is not installed"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Nginx configuration completed" 