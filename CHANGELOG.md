# Changelog

## [1.1.0] - 2025-12-28

### Changed

- **Provider Architecture**: Major refactoring of provider structure for improved maintainability and code cleanliness
  - Simplified MVVM pattern by removing redundancies
  - Added factory constructor `Earthquake.fromFeature()` to eliminate code duplication
  - Optimized provider dependencies and removed unnecessary providers
  - Streamlined `selectedEarthquakeProvider` and `allEarthquakesProvider` for better performance

- **Map Improvements**: Enhanced map UI and interaction management
  - Improved initial zoom level when opening earthquake details (now 12.0 for better detail view)
  - Fixed "center on user location" button functionality with proper zoom level (14.0)
  - Implemented in-place event selection system: clicking map markers now updates the detail view without navigation
  - Fixed marker contrast: events with magnitude < 2.0 now display black text and border on white background for better readability
  - Enhanced MapController management for smoother map interactions

- **Code Quality**: Comprehensive code cleanup
  - Improved error handling in provider initialization

### Fixed

- **Provider State Management**: Fixed unsafe provider access in `dispose()` methods using `Future.microtask()`
- **Map Navigation**: Fixed map not centering on selected earthquake when opening detail page
- **Location Providers**: Fixed distance calculation using correct geometry accessors
- **Filter Dialog**: Fixed reference to non-existent `defaultSettingsProvider`

## [1.0.0] - 2025-12-14

### Added

- **Multi-Source Support**: Added USGS (World) as a selectable data source alongside INGV (Italy).
- **Data Source Settings**: New dedicated settings page for selecting earthquake data provider.
- **Interactive Map**: Map markers are now clickable and navigate to the respective earthquake detail page.
- **Global Event Visibility**: Detail map now displays all filtered events as smaller markers for better context.

### Changed

- **Navigation**: Improved back navigation from map interactions to always return to the event list.
- **UI/UX**: Refined earthquake detail view to dynamically hide missing data fields (e.g., when viewing USGS events).
- **Settings**: Modernized settings UI, replacing dialogs with dedicated pages for a consistent experience.
- **Localization**: Added full Italian/English support for new features.

### Fixed

- **Notifications**: Disabled notification UI temporarily pending Firebase integration.

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
