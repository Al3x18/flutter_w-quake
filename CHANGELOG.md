# Changelog

## [0.9.0] - 2025-10-29

### Added

- App icon generation for Android/iOS via `flutter_launcher_icons`
- Native splash screen for Android (incl. Android 12) e iOS via `flutter_native_splash`

## [0.8.6] - 2025-10-29

### Fixed

- **Location settings bug**: Fixed issue where disabling location in settings didn't properly disable location features until app restart
  - Location stream now respects `locationEnabled` and `showUserLocation` settings
  - Proximity indicators and "near you" badges now immediately disappear when location is disabled
  - Map center-on-user button now properly disables when location is turned off
  - Added provider invalidation to ensure immediate UI updates when settings change

## [0.8.5] - 2025-10-29

### Fixed

- Home proximity indicator on first launch: immediate bootstrap of location stream via `async*` in `userPositionProvider` (`getCurrentPosition` + `startLocationUpdates`, then `yield*`), plus reactive proximity providers. The near-you indicator now appears on first Home load without navigation.

## [0.8.0] - 2025-10-29

### Added

- **Nearby earthquakes indicator**: Events within user-defined radius are marked with orange indicators
- **Location radius settings**: Configurable search radius (20-300 km) with real-time updates
- **Enhanced location features**: 
  - Orange vertical bar on earthquake cards for nearby events
  - "Near you" badge in earthquake details when within radius
  - Real-time indicator updates when changing radius settings
- **Improved UX**: Visual feedback for proximity-based earthquake filtering

## [0.7.0] - 2025-10-28

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

## [0.6.0] - 2025-10-27

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
