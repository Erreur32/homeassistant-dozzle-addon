# run.sh
#!/usr/bin/with-contenv bashio

# Print a message indicating that Dozzle is starting
echo "Starting Dozzle..."

# Run the Dozzle container with the necessary configurations
docker run --rm \
    --network=host \  # Use the host network mode to ensure full connectivity
    -e DOZZLE_BASE=/api/panel \  # Set the base path for Dozzle when running in Home Assistant
    -v /var/run/docker.sock:/var/run/docker.sock \  # Mount the Docker socket to allow access to logs
    amir20/dozzle:latest
