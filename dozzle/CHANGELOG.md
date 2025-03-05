# Changelog
<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->

## 0.1.49

- ⚠️ Known Issue: Ingress is currently not working. Please use direct access via port 8099
- Fixed various script issues
- Improved error handling
- Updated documentation with current limitations

## 0.1.47

### 🚀 Improvements
- ✨ Proper implementation of Home Assistant ingress
- 🔄 Using dynamic ingress entry point
- 🛠️ Fixed ingress configuration issues
- 🔒 Enhanced security with Home Assistant authentication

## 0.1.46

### 🔧 Changes
- Added SSL support with automatic certificate generation
- Added password protection option
- Added SSL configuration options in add-on settings
- Updated documentation with SSL information
- Aligned configuration with Portainer's working setup
- Improved token management for Home Assistant

## 0.1.45

### 🔧 Changes
- Aligned configuration with Portainer's working setup
- Simplified ingress configuration
- Optimized token management
- Improved SSL support
- Updated documentation

## 0.1.44

### 🔧 Changes
- Fixed add-on visibility in Home Assistant store
- Removed explicit SUPERVISOR_TOKEN configuration
- Simplified ingress authentication handling
- Improved script structure and error handling

## 0.1.43

### 🔧 Changes
- Fixed ingress authentication with SUPERVISOR_TOKEN
- Optimized TCP proxy configuration
- Improved environment variable management
- Fixed authentication errors in logs

## 0.1.42

### 🔧 Changes
- Updated run.sh script to handle agent mode
- Added agent and agent_port options in configuration
- Improved documentation for agent mode
- Updated architecture badges in documentation
- Enhanced build configuration
- Improved path handling

## 0.1.41

### 🔧 Changes
- Updated Dozzle to version 8.11.7
- Added dozzle.version label in Dockerfile
- Improved logs for agent mode
- Updated documentation with Dozzle version

## 0.1.40

### 🚀 New Features
- ✨ Added Dozzle agent mode
- 🔧 Configurable agent port
- 🔄 Agent mode support with default port 8098

### 🔧 Changes
- Updated ingress configuration
- Added auth_api support
- Improved error handling
- Enhanced ingress documentation

## 0.1.39

### 🔄 Revert
- Reverted to last known working configuration
- Restored ingress path to "/ingress"
- Fixed external access configuration

### 🐛 Bug Fixes
- Fixed ingress path configuration
- Added proper authentication for Home Assistant
- Corrected base path for ingress access
- Fixed JSON parsing errors

## 0.1.38

### 🚀 New Features
- Added automatic log cleaning option at startup
- Added log cleaning function
- Added configuration option `clean_logs_on_start`

### 🔧 Changes
- Updated documentation with log cleaning information
- Improved startup logging messages

## 0.1.37

### 🐛 Bug Fixes
- Fixed ingress configuration and routing
- Corrected environment variables for proper ingress support
- Updated device paths format for better compatibility
- Fixed JSON parsing errors in configuration

### 🔧 Changes
- Simplified port configuration
- Removed unnecessary privileges and mappings
- Improved error messages
- Enhanced ingress integration with Home Assistant

## 0.1.36

### 🐛 Bug Fixes
- Fixed watchdog configuration format
- Updated device paths to new format
- Changed hassio_role to "default"
- Removed deprecated Docker socket mapping format

### 🔧 Changes
- Simplified environment variables
- Updated all version references
- Cleaned up configuration structure
- Improved documentation consistency

## 0.1.35

### 🐛 Bug Fixes
- Fixed bashio script errors
- Fixed ingress authentication issues
- Fixed Docker socket access
- Corrected environment variables configuration

### 🔧 Changes
- Improved error handling in startup script
- Enhanced logging configuration
- Simplified ingress configuration
- Removed deprecated configuration options

## 0.1.34

### 🚀 New Features
- Added configurable port option in Home Assistant UI
- Added log level configuration option
- Added auto-update option
- Improved ingress support for direct Home Assistant integration

### 🔧 Changes
- Updated documentation with new configuration options
- Improved error handling and logging
- Added detailed configuration instructions
- Enhanced Docker socket error detection

### 🐛 Bug Fixes
- Fixed routing pattern issue with ingress path
- Corrected environment variable configuration
- Fixed Docker socket mounting issues

## 0.1.33

### 🎉 Initial Release
- Basic Dozzle integration with Home Assistant
- Real-time Docker log viewing
- Direct access via ingress
- Basic configuration options

## [0.1.32] - 2024-03-xx

### Added
- ✨ Ingress support for direct Home Assistant UI integration
- 🔒 Improved security configuration
- 🔄 Auto-update capability
- 📝 Enhanced documentation and README
- 🐳 Better Docker socket handling

### Changed
- 🚀 Updated base image to latest Home Assistant AMD64 base
- ⚡️ Optimized Docker configuration
- 🔧 Improved startup script with better error handling
- 🎨 Better logging with bashio

### Fixed
- 🐛 Docker socket permissions handling
- 🔍 Path resolution for ingress support
- 🔐 Security-related configurations

## [1.2.0] - 2023

### Added
- AppArmor profile for enhanced security
- Sample script for service running with AppArmor constraints

### Changed
- Updated to 3.15 base image with s6 v3
- Improved service management

## [1.1.0] - 2023

### Changed
- General updates and improvements
- Enhanced stability

## [1.0.0] - 2023

### Added
- Initial release of Dozzle add-on
- Basic Docker log viewing functionality
- External access support
