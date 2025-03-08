# Home Assistant Add-on: Dozzle

[![Release][release-shield]][release]
![Project Stage][project-stage-shield]
![Project Maintenance][maintenance-shield]
[![License][license-shield]][license]
[![Issues][issues-shield]][issue]
[![Stargazers][stars-shield]][stars]



## About

![Dozzle Screenshot](https://github.com/user-attachments/assets/b184931c-03d4-4e8a-b716-a9b17055892d)

[Dozzle](https://github.com/amir20/dozzle) is a lightweight real-time Docker log monitoring tool with a web interface.

This version is optimized to work as a **Home Assistant add-on** with improved **Ingress support**.

>⚠️ **This is not an official add-on from Dozzle!**  

---

## 🚀 **Features of Dozzle**  

✔️ Intuitive web interface for Docker log visualization  
✔️ Real-time log updates  
✔️ Agent mode for distributed logging  

---

## 🏠 **Enhancements for Home Assistant**  

🔐 **SSL support** with automatic certificate generation  
🔑 **Password protection**  
🔗 **Ingress support** for direct integration into Home Assistant  

---

## 🛠 **Installation**  

1. **Open the Home Assistant Add-on Store**:  
   [📌 Access the Store](https://my.home-assistant.io/redirect/supervisor_store/)  

2. **Search for "Dozzle"** in the Add-on Store  
3. **Install the add-on** and wait for the process to complete  
4. **Start Dozzle**  

  🔗 **Access Dozzle once installed**:  
      [📌 Open Dozzle](https://my.home-assistant.io/redirect/supervisor_addon/?addon=dozzle)  

  🏗 **Add an external repository containing Dozzle** (if necessary):  
      [📌 Add Repository](https://my.home-assistant.io/redirect/supervisor_addon_store/?repository_url=https://github.com/Erreur32/homeassistant-dozzle-addon)  

---

💬 **Need help?** Check the [official documentation](https://github.com/amir20/dozzle) or ask for assistance in the Home Assistant community.

---

🛠 **Optimized text** with direct links for a smoother installation! 🚀



## Configuration

### Basic Options

```yaml
# Port for external access (optional)
port: 8099
# Agent mode (for Docker Swarm installations)
agent: false
# Log level (debug, info, error)
log_level: info

```

## Usage

### External Access

1. Configure the port in the add-on options
2. Access the interface via `http://[HA-IP]:[PORT]`
3. Example: `http://192.168.1.100:8099`

## Support

Got questions?

You can open an issue here: [issue tracker][issue]

## Contributing

This is an active open-source project. We are always open to people who want to use
the code or contribute back to it.

Thank you for being involved! :heart_eyes:

## Authors & contributors

The original setup of this repository is by [Erreur32][erreur32].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## License

MIT License - see the [LICENSE.md][license] file for details

[contributors]: https://github.com/Erreur32/homeassistant-dozzle-addon/graphs/contributors
[erreur32]: https://github.com/Erreur32
[issue]: https://github.com/Erreur32/homeassistant-dozzle-addon/issues
[license]: https://github.com/Erreur32/homeassistant-dozzle-addon/blob/main/LICENSE.md
[maintenance-shield]: https://img.shields.io/maintenance/yes/2024.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg
[release-shield]: https://img.shields.io/badge/version-v0.1.51-blue.svg
[release]: https://github.com/Erreur32/homeassistant-dozzle-addon/releases/tag/v0.1.51
[license-shield]: https://img.shields.io/badge/license-MIT-blue.svg
[issues-shield]: https://img.shields.io/github/issues/Erreur32/homeassistant-dozzle-addon.svg
[stars-shield]: https://img.shields.io/github/stars/Erreur32/homeassistant-dozzle-addon.svg
[stars]: https://github.com/Erreur32/homeassistant-dozzle-addon/stargazers
