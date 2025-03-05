# Dozzle

[![Release][release-shield]][release]
![Project Stage][project-stage-shield]
![Project Maintenance][maintenance-shield]
[![License][license-shield]][license]
[![Issues][issues-shield]][issue]
[![Stargazers][stars-shield]][stars]

Real-time Docker log monitoring interface for Home Assistant.

## About

Dozzle is a lightweight real-time Docker log monitoring tool with a web interface. This version (0.1.46) is optimized to work as a Home Assistant add-on with improved ingress support.

## Features

- Intuitive web interface for Docker log visualization
- Real-time log updates
- SSL support with automatic certificate generation
- Password protection
- Ingress support for direct Home Assistant integration
- Agent mode for distributed logging
- Automatic log cleaning option
- Configurable log level

## Installation

1. Add the repository to your Home Assistant instance:
   ```yaml
   repositories:
     - https://github.com/Erreur32/homeassistant-dozzle-addon
   ```

2. Search for "Dozzle" in the Home Assistant Add-on Store

3. Click "Install"

4. Start the add-on

## Configuration

### Basic Options

```yaml
# Port for external access (optional)
port: 8099

# Log level (debug, info, warn, error)
log_level: info

# Automatic log cleaning at startup
auto_clean_logs: false

# Agent mode (for Docker Swarm installations)
agent: false
```

## Usage

### Access via Ingress

1. Access the interface through the Home Assistant add-on panel
2. Click "Open Web UI"
3. The Dozzle interface will open in a new tab

### External Access

1. Configure the port in the add-on options
2. Access the interface via `http://[HA-IP]:[PORT]`
3. Example: `http://192.168.1.100:8099`

## Support

Got questions?

You can open an issue here: [Dozzle issue tracker][issue]

## Contributing

This is an active open-source project. We are always open to people who want to use
the code or contribute back to it.

Thank you for being involved! :heart_eyes:

## Authors & contributors

The original setup of this repository is by [Erreur32][erreur32].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## License

MIT License - see the [LICENSE][license] file for details

[contributors]: https://github.com/Erreur32/homeassistant-dozzle-addon/graphs/contributors
[erreur32]: https://github.com/Erreur32
[issue]: https://github.com/Erreur32/homeassistant-dozzle-addon/issues
[license]: https://github.com/Erreur32/homeassistant-dozzle-addon/blob/main/LICENSE
[maintenance-shield]: https://img.shields.io/maintenance/yes/2024.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg
[release-shield]: https://img.shields.io/badge/version-v0.1.48-blue.svg
[release]: https://github.com/Erreur32/homeassistant-dozzle-addon/releases/tag/v0.1.48
[license-shield]: https://img.shields.io/github/license/Erreur32/homeassistant-dozzle-addon.svg
[issues-shield]: https://img.shields.io/github/issues/Erreur32/homeassistant-dozzle-addon.svg
[stars-shield]: https://img.shields.io/github/stars/Erreur32/homeassistant-dozzle-addon.svg
[stars]: https://github.com/Erreur32/homeassistant-dozzle-addon/stargazers
