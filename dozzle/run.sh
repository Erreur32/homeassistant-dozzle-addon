#!/usr/bin/with-contenv bashio

set -e

# port variable ext.
# Définir le port : si la config HA existe, on la prend, sinon on met 8099 par défaut
#PORT=$(bashio::config 'port' || echo "8099")

#ingress
PORT=8099

echo "Starting Dozzle on port ${PORT}..."

if [ ! -f "/usr/local/bin/dozzle" ]; then
    echo "Error: Dozzle binary not found in /usr/local/bin/dozzle"
    exit 1
fi

exec /usr/local/bin/dozzle --addr :${PORT}

# Démarrer Dozzle
#exec /usr/local/bin/dozzle --addr :${PORT}
# Lancer en arrière-plan pour éviter les conflits PID avec s6
#nohup /usr/local/bin/dozzle --addr :${PORT} > /dev/stdout 2>&1 &
 
# Run the Dozzle container with the necessary configurations
#docker run --rm \
#    --network=host \  # Use the host network mode to ensure full connectivity
#    -e DOZZLE_BASE=/api/panel \  # Set the base path for Dozzle when running in Home Assistant
#    -v /var/run/docker.sock:/var/run/docker.sock \  # Mount the Docker socket to allow access to logs
#    amir20/dozzle:latest
