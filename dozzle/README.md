# Home Assistant Add-on: Dozzle

[![Release][release-shield]][release] ![Project Stage][project-stage-shield] ![Project Maintenance][maintenance-shield]

Dozzle est une interface web en temps réel pour visualiser les logs Docker dans Home Assistant.

![logo](https://github.com/user-attachments/assets/b184931c-03d4-4e8a-b716-a9b17055892d)

## About

[Dozzle](https://dozzle.dev/) is a real-time log viewer for Docker containers, now available as a Home Assistant add-on. It provides a clean web interface to monitor and debug your Docker containers directly from your Home Assistant interface.

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FErreur32t%2Fhomeassistant-dozzle-addon)

## Features

- 🔍 Real-time log viewing
- 🏠 Direct integration in Home Assistant UI (Ingress support)
- 🔄 Auto-update capability
- 🔒 Secure access through Home Assistant
- 🐳 Support for all Docker containers

## Installation

1. Click the "Add repository to Home Assistant" button above
2. Navigate to the Home Assistant Add-on Store
3. Find the "Dozzle" add-on and click install
4. Start the add-on
5. Access Dozzle directly from your Home Assistant sidebar

## Configuration

### Add-on Configuration

The add-on provides several configuration options:

```yaml
auto_update: true  # Enable automatic updates
protected: false   # Allow access without authentication
```

### Access Methods

You can access Dozzle in two ways:
1. **Recommended**: Directly through Home Assistant UI (Ingress)
2. External access via `http://homeassistant:8099` (if needed)

## Security Recommendations

- Consider enabling authentication if exposing to external networks
- Review Docker socket permissions
- Keep the add-on updated

## Supported Architectures

![Supports amd64 Architecture][amd64-shield]

## Support

- [Report an issue](https://github.com/Erreur32/homeassistant-dozzle-addon/issues)
- [Dozzle Documentation](https://dozzle.dev/)

## License

This Home Assistant add-on is licensed under MIT License.

## Add-ons

> [!IMPORTANT]
> Acces only via external URL eg. http://homeassistant:8099 .


This repository contains the following add-ons
### [Dozzle Agent add-on](./dozzle-agent)

## Settings
 Disable
 - Protected mod : off


## TODO:
- [x] Ingress directly in HA ;)
- [x] Secure access

## Versions

- Version actuelle : 0.1.35
- Basé sur Dozzle et Alpine Linux 3.15

[release-shield]: https://img.shields.io/badge/version-v0.1.35-blue.svg
[release]: https://github.com/Erreur32/homeassistant-dozzle-addon/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2024.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

# Home Assistant Add-on: Dozzle

[![Release][release-shield]][release] ![Project Stage][project-stage-shield] ![Project Maintenance][maintenance-shield]

Dozzle est une interface web en temps réel pour visualiser les logs Docker dans Home Assistant.

![logo](https://github.com/user-attachments/assets/b184931c-03d4-4e8a-b716-a9b17055892d)

## About

[Dozzle](https://dozzle.dev/) is a real-time log viewer for Docker containers, now available as a Home Assistant add-on. It provides a clean web interface to monitor and debug your Docker containers directly from your Home Assistant interface.

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FErreur32t%2Fhomeassistant-dozzle-addon)

## Features

- 🔍 Real-time log viewing
- 🏠 Direct integration in Home Assistant UI (Ingress support)
- 🔄 Auto-update capability
- 🔒 Secure access through Home Assistant
- 🐳 Support for all Docker containers

## Installation

1. Click the "Add repository to Home Assistant" button above
2. Navigate to the Home Assistant Add-on Store
3. Find the "Dozzle" add-on and click install
4. Start the add-on
5. Access Dozzle directly from your Home Assistant sidebar

## Configuration

### Add-on Configuration

The add-on provides several configuration options:

```yaml
auto_update: true  # Enable automatic updates
protected: false   # Allow access without authentication
```

### Access Methods

You can access Dozzle in two ways:
1. **Recommended**: Directly through Home Assistant UI (Ingress)
2. External access via `http://homeassistant:8099` (if needed)

## Security Recommendations

- Consider enabling authentication if exposing to external networks
- Review Docker socket permissions
- Keep the add-on updated

## Supported Architectures

![Supports amd64 Architecture][amd64-shield]

## Support

- [Report an issue](https://github.com/Erreur32/homeassistant-dozzle-addon/issues)
- [Dozzle Documentation](https://dozzle.dev/)

## License

This Home Assistant add-on is licensed under MIT License.

## Add-ons

> [!IMPORTANT]
> Acces only via external URL eg. http://homeassistant:8099 .


This repository contains the following add-ons
### [Dozzle Agent add-on](./dozzle-agent)

## Settings
 Disable
 - Protected mod : off


## TODO:
- [x] Ingress directly in HA ;)
- [x] Secure access

## Versions

- Version actuelle : 0.1.34
- Basé sur Dozzle et Alpine Linux 3.15

[release-shield]: https://img.shields.io/badge/version-v0.1.34-blue.svg
[release]: https://github.com/Erreur32/homeassistant-dozzle-addon/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2024.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
