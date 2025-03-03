# Dozzle

## Overview

Dozzle is a real-time log viewer for Docker containers. This add-on provides a simple web interface to monitor your Docker container logs directly from Home Assistant.

## Features

- Real-time log streaming
- No log storage - reads directly from Docker
- Clean and intuitive web interface
- Native Home Assistant integration
- Secure access through Home Assistant authentication
- Configurable port and logging options

## Installation

1. Navigate to the Home Assistant Supervisor panel
2. Click on "Add-on Store"
3. Click on the 3-dots menu at the top right and select "Repositories"
4. Add this repository URL: `https://github.com/Erreur32/homeassistant-dozzle-addon`
5. Find "Dozzle" in the list and click "Install"

## Configuration

The add-on offers several configuration options that can be modified in the add-on configuration panel:

```yaml
# Example configuration
port: 8099              # The port Dozzle will run on
log_level: info         # The log level (trace/debug/info/notice/warning/error/fatal)
auto_update: false      # Enable/disable automatic updates
```

### Option: `port`

The port number that Dozzle will use. Default is `8099`. Change this if the port is already in use by another service.

### Option: `log_level`

The `log_level` option controls the level of log output by the add-on and can be changed to be more or less verbose, which might be useful when you are dealing with an unknown problem. Possible values are:

- `trace`: Show every detail, like all called internal functions
- `debug`: Shows detailed debug information
- `info`: Normal (usually) interesting events
- `notice`: Important events
- `warning`: Exceptional occurrences that are not errors
- `error`: Runtime errors that do not require immediate action
- `fatal`: Something went terribly wrong. Add-on becomes unusable

### Option: `auto_update`

Enable this to automatically update the add-on when new versions are available.

## Network

- Default port: 8099 (configurable)
- The add-on runs on the host network for direct access to Docker logs
- Ingress is enabled for easy access through Home Assistant UI

## Storage

This add-on doesn't store any data. All logs are read directly from Docker in real-time.

## Support

Need help? Found a bug? Please [open an issue](https://github.com/Erreur32/homeassistant-dozzle-addon/issues) on our GitHub repository.

## Frequently Asked Questions

### Q: Why can't I see any containers?
A: Check if Docker socket is properly mounted and verify Docker API access permissions.

### Q: How do I change the port?
A: Go to the add-on configuration page and modify the `port` option to your desired port number.

### Q: Is authentication required?
A: By default, the add-on uses Home Assistant authentication. You can enable additional protection by setting `protected: true` in the add-on configuration.

### Q: Does it affect performance?
A: Dozzle is very lightweight and only reads logs when requested. It doesn't store any data locally.

## More Information

For more details about Dozzle itself, visit [dozzle.dev](https://dozzle.dev/) 