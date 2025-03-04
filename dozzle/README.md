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
- 🧹 Automatic log cleaning option
- 🖥️ Multi-architecture support
- 🔐 Enhanced ingress security

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
auto_update: true          # Enable automatic updates
protected: false           # Need to be set on FALSE to work!
clean_logs_on_start: false # Clean container logs on addon startup
log_level: "info"          # Set logging level
```

### Access Methods

You can access Dozzle in two ways:
1. **Recommended**: Directly through Home Assistant UI (Ingress)
2. External access via `http://homeassistant:8099`

Both access methods are now properly configured and should work simultaneously.

### Ingress Access

The add-on now properly supports Home Assistant ingress:
- Access through the Home Assistant sidebar
- Proper authentication handling
- Secure access through Home Assistant's reverse proxy
- Simplified base path configuration
- SSL support through Home Assistant's certificates
- WebUI integration for better accessibility

### Log Management

The add-on now includes automatic log cleaning capabilities:

- **Automatic Cleaning**: Enable `clean_logs_on_start` to automatically clean all container logs when the add-on starts
- **Manual Cleaning**: You can manually clean logs by restarting the add-on with `clean_logs_on_start` enabled

## Security Recommendations

> [!IMPORTANT]
>
>  - Consider enabling authentication if exposing to external networks
>  - Review Docker socket permissions
>  - Keep the add-on updated
>  - Be cautious with log cleaning in production environments
>  - Use ingress for secure access through Home Assistant

## Supported Architectures

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

## Support

- [Report an issue](https://github.com/Erreur32/homeassistant-dozzle-addon/issues)
- [Dozzle Documentation](https://dozzle.dev/)

## License

This Home Assistant add-on is licensed under MIT License.

## Version Information

- Current Version: 0.1.42
- Based on Dozzle v8.11.7 and Alpine Linux 3.15

[release-shield]: https://img.shields.io/badge/version-v0.1.42-blue.svg
[release]: https://github.com/Erreur32/homeassistant-dozzle-addon/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2024.svg
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
