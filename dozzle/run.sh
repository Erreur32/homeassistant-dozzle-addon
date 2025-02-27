#!/usr/bin/with-contenv bashio
# run.sh
# Print a message indicating that Dozzle is starting
echo "Starting Dozzle..."
 #!/usr/bin/with-contenv bashio

 

# Utilisez bashio pour lire les options de configuration
CONFIG_PATH=/data/options.json

# Exemple de lecture d'une option de configuration
DOZZLE_LEVEL=$(bashio::config 'DOZZLE_LEVEL')

# Commande pour démarrer Dozzle
exec dozzle --level "$DOZZLE_LEVEL"



# Start Dozzle in the foreground (correct execution)
#exec /usr/bin/dozzle --host 0.0.0.0 --port 8666

# Run the Dozzle container with the necessary configurations
#docker run --rm \
#    --network=host \  # Use the host network mode to ensure full connectivity
#    -e DOZZLE_BASE=/api/panel \  # Set the base path for Dozzle when running in Home Assistant
#    -v /var/run/docker.sock:/var/run/docker.sock \  # Mount the Docker socket to allow access to logs
#    amir20/dozzle:latest
