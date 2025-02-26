#!/usr/bin/with-contenv bashio

# Print a message indicating that Dozzle is starting
# Debug : afficher les logs au démarrage
echo "🚀 Dozzle Add-on is starting..."
export BASHIO_LOG_LEVEL="debug"

# Lancer Dozzle directement via Docker
docker run --rm \
  --network=host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  amir20/dozzle:latest
# Vérifier si Bashio fonctionne
if ! command -v bashio &> /dev/null; then
    echo "❌ Bashio not found! Exiting..."
    exit 1
fi

# Start Dozzle in the foreground (correct execution)
exec /usr/bin/dozzle --host 0.0.0.0 --port 8666

