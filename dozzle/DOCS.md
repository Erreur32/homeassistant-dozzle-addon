# Dozzle

## Overview

Dozzle is a real-time log viewer for Docker containers. This add-on provides a simple web interface to monitor your Docker container logs directly from Home Assistant.

## Features

- Real-time log streaming
- No log storage - reads directly from Docker
- Clean and intuitive web interface
- Native Home Assistant integration
- Secure access through Home Assistant authentication

## Installation

1. Navigate to the Home Assistant Supervisor panel
2. Click on "Add-on Store"
3. Click on the 3-dots menu at the top right and select "Repositories"
4. Add this repository URL: `https://github.com/Erreur32/homeassistant-dozzle-addon`
5. Find "Dozzle" in the list and click "Install"

## How to use

1. Start the add-on
2. Click "OPEN WEB UI" to access Dozzle
3. You will see a list of all your Docker containers
4. Click on any container to view its logs in real-time

## Configuration

The add-on comes with a default configuration that works out of the box:

```yaml
ingress: true
ingress_port: 8099
docker_api: true
```

### Optional Configuration

- `protected`: Enable this if you want to require authentication
- `host_network`: Can be disabled if you don't need host network access

## Network

- Ingress port: 8099 (internal)
- You can also access directly via `http://homeassistant:8099` (if needed)

## Storage

This add-on doesn't store any data. All logs are read directly from Docker in real-time.

## Support

Need help? Found a bug? Please [open an issue](https://github.com/Erreur32/homeassistant-dozzle-addon/issues) on our GitHub repository.

## Frequently Asked Questions

### Q: Why can't I see any containers?
A: Check if Docker socket is properly mounted and verify Docker API access permissions.

### Q: Is authentication required?
A: By default, the add-on uses Home Assistant authentication. You can enable additional protection by setting `protected: true`.

### Q: Does it affect performance?
A: Dozzle is very lightweight and only reads logs when requested. It doesn't store any data locally.

## More Information

For more details about Dozzle itself, visit [dozzle.dev](https://dozzle.dev/) 