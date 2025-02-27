#!/usr/bin/with-contenv bashio
<<<<<<< HEAD
# run.sh
# Print a message indicating that Dozzle is starting
echo "Starting Dozzle..."
 #!/usr/bin/with-contenv bashio

# Utilisez bashio pour lire les options de configuration
DOZZLE_LEVEL=$(bashio::config 'DOZZLE_LEVEL')
DOZZLE_TAILSIZE=$(bashio::config 'DOZZLE_TAILSIZE')
DOZZLE_FILTER=$(bashio::config 'DOZZLE_FILTER')

# Commande pour démarrer Dozzle avec les options configurées
exec dozzle --level "$DOZZLE_LEVEL" --tail "$DOZZLE_TAILSIZE" --filter "$DOZZLE_FILTER"



# Start Dozzle in the foreground (correct execution)
#exec /usr/bin/dozzle --host 0.0.0.0 --port 8666
=======

set -e

# Affiche un message dans les logs de l'add-on
echo "Starting Dozzle on port 8099..."

# Vérifier que le fichier binaire existe avant de l'exécuter
if [ ! -f "/usr/local/bin/dozzle" ]; then
    echo "Error: Dozzle binary not found in /usr/local/bin/dozzle"
    exit 1
fi

# Démarrer Dozzle
exec /usr/local/bin/dozzle --addr :8099

>>>>>>> 88f893c (Mise à jour de l'addon Dozzle pour HA)

# Run the Dozzle container with the necessary configurations
#docker run --rm \
#    --network=host \  # Use the host network mode to ensure full connectivity
#    -e DOZZLE_BASE=/api/panel \  # Set the base path for Dozzle when running in Home Assistant
#    -v /var/run/docker.sock:/var/run/docker.sock \  # Mount the Docker socket to allow access to logs
#    amir20/dozzle:latest
