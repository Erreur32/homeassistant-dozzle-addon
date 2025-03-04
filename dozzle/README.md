# Dozzle for Home Assistant

[![Release][release-shield]][release]
![Project Stage][project-stage-shield]
![Project Maintenance][maintenance-shield]

[![Discord][discord-shield]][discord]
[![Community Forum][forum-shield]][forum]

[![Buy me a coffee][buymeacoffee-shield]][buymeacoffee]

Real-time Docker log monitoring interface for Home Assistant.

## About

Dozzle is a lightweight real-time Docker log monitoring tool with a web interface. This version is optimized to work as a Home Assistant add-on.

## Features

- Intuitive web interface for Docker log visualization
- Real-time log updates
- Home Assistant ingress support
- Configurable external access
- Log filtering and search
- Docker and Docker Swarm container support
- Modern responsive interface

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

For any questions or issues, please:
1. Check the [documentation][docs]
2. Visit the [community forum][forum]
3. Join the [Discord][discord] server

## Contributing

Contributions are welcome! Feel free to:
1. Fork the project
2. Create a branch for your feature
3. Submit a pull request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Credits

- [Dozzle][dozzle] - The original project
- [Home Assistant][home-assistant] - The home automation platform
- [Docker][docker] - The containerization platform

[release-shield]: https://img.shields.io/github/v/release/Erreur32/homeassistant-dozzle-addon?include_prereleases&style=flat-square
[release]: https://github.com/Erreur32/homeassistant-dozzle-addon/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production%20ready-brightgreen.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2024.svg
[discord-shield]: https://img.shields.io/discord/330944238910963714.svg
[discord]: https://discord.gg/c5DvZ4e
[forum-shield]: https://img.shields.io/badge/community-forum-brightgreen.svg
[forum]: https://community.home-assistant.io/
[buymeacoffee-shield]: https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg
[docs]: https://github.com/Erreur32/homeassistant-dozzle-addon/wiki
[dozzle]: https://github.com/amir20/dozzle
[home-assistant]: https://home-assistant.io
[docker]: https://www.docker.com
