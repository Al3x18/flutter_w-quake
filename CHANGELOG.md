# Changelog

## [0.7.0] - 2025-01-28

### Architecture Improvements

- **Major architecture simplification**: Reduced provider complexity 
- **Unified provider structure**: Consolidated earthquake, language, and information providers
- **Streamlined provider files**: 
  - `earthquake_providers.dart`: Centralized main providers
  - `location_providers.dart`: Essential location providers only 
  - `language_providers.dart`: Minimal service provider
  - `information_providers.dart`: Minimal service provider
- **Enhanced maintainability**: Single source of truth for main application logic
- **Improved code organization**: Clear separation of concerns between service, viewmodel, and state providers
- **Reduced code duplication**: Eliminated redundant provider definitions
- **Better performance**: Optimized provider structure with computed providers
- **Enhanced LocationService**: Added distance calculation and formatting methods

## [0.6.0] - 2025-01-27

### Added

- Interactive earthquake detail screen with expandable container
- Interactive map integration with flutter_map
- User location display and auto-centering on map
- Location permission management with adaptive UI
- Enhanced earthquake detail expansion widget
- Custom map widgets with earthquake markers
- Location services integration (geolocator, permission_handler)
- Adaptive UI components (RefreshIndicator.adaptive, Switch.adaptive)
- Enhanced app title styling

## [0.5.0] - 2025-10-25

### Added

- Initial project setup with Flutter
- MVVM architecture implementation
- Go Router navigation system
- Riverpod state management
- Multi-language support (English/Italian)
- Dark theme with custom styling
- Real-time earthquake data fetching
- Filter system for earthquake events
- Statistics display
- Settings management
- Custom UI widgets and components
- JSON serialization for earthquake data models
- Shared preferences for settings storage
- Google Fonts integration
- Internationalization support
