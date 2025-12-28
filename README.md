# W-Quake

A Flutter application for monitoring and displaying earthquake data in real-time.

## Project Status

🚧 **Work in Progress** - This project is currently under active development.

## Architecture

This project follows the **MVVM (Model-View-ViewModel)** architectural pattern with the following key technologies:

- **Flutter** - Cross-platform mobile framework
- **Go Router** - Declarative routing solution for Flutter
- **Riverpod** - State management and dependency injection
- **MVVM Pattern** - Clean separation of concerns

## Data Sources

The application supports multiple earthquake data sources that can be selected in the settings:

### INGV (Istituto Nazionale di Geofisica e Vulcanologia)

**Base URL:** `https://webservices.ingv.it/fdsnws/event/1/query`

Primary data source for Italian and European earthquakes.

#### Supported Parameters

The API supports the following query parameters for filtering earthquake events:

|Parameter|Type|Description|
|---------|----|----------|
|`format`|string|Response format (using `geojson`)|
|`starttime`|ISO date|Start date for event search (ISO 8601 format: YYYY-MM-DD)|
|`endtime`|ISO date|End date for event search (ISO 8601 format: YYYY-MM-DD)|
|`minmagnitude`|double|Minimum earthquake magnitude|
|`minlatitude`|double|Minimum latitude (South boundary)|
|`maxlatitude`|double|Maximum latitude (North boundary)|
|`minlongitude`|double|Minimum longitude (West boundary)|
|`maxlongitude`|double|Maximum longitude (East boundary)|

#### Geographic Coverage

The app provides pre-configured geographic filters:

- **🌍 World**: Global coverage (no geographic limits)
- **🇮🇹 Italy**: 35°-47°N, 6°-19°E (includes Sicily, Sardinia, and all Italian territory)
- **🇪🇺 Europe**: 35°-71°N, -25°-45°E (from Mediterranean to Northern Scandinavia)
- **🌏 Asia**: -10°-77°N, 25°-180°E (from Indonesia to Siberia, includes Middle East, India, China, Japan)
- **🌎 Americas**: -60°-85°N, -180°--30°W (from Patagonia to Alaska)

#### API Limitations

- **Date Range**: Data available from **1985-01-01** onwards
- **Max Date Range**: Recommended not to exceed 10 years per query
- **Response Codes**:
  - `200`: Success with data
  - `204`: No content (no earthquakes in specified range)
  - `400`: Bad request (invalid parameters)
  - `413`: Too many events (reduce date range or increase magnitude filter)
  - `500/503`: Server error or service unavailable

For more information, visit: [INGV Web Services Documentation](https://webservices.ingv.it/)

### USGS (United States Geological Survey)

**Base URL:** `https://earthquake.usgs.gov/fdsnws/event/1/query`

Global earthquake data source providing worldwide coverage. Supports the same FDSN Web Service standard as INGV.

**Features:**

- Global earthquake coverage
- Real-time and historical data
- Same query parameters as INGV API
- Compatible with all geographic filters

For more information, visit: [USGS Earthquake API Documentation](https://earthquake.usgs.gov/fdsnws/event/1/)

## Features

### ✅ Implemented

- **Multi-source support**: Real-time earthquake data from INGV (Italy/Europe) and USGS (Global)
- **Data source selection**: Switch between INGV and USGS in settings
- Multi-language support (English/Italian)
- Dark theme with custom styling
- Advanced filtering (geographic area, magnitude, date range)
- Statistics display with expandable cards
- Settings management with persistent storage
- MVVM architecture with Riverpod state management
- **Interactive earthquake detail screen** with expandable container
- **Interactive map view** with earthquake locations and markers
- **In-place event selection**: Click map markers to update detail view without navigation
- **User location display** and auto-centering functionality
- **Location permission management** with adaptive UI
- **Nearby earthquakes indicator** with configurable radius (20-300 km)
- **Real-time proximity filtering** with visual indicators
- **Enhanced map interactions**: Improved zoom levels and smooth map transitions
- **Marker contrast optimization**: Better readability for low-magnitude events
- **Adaptive UI components** (RefreshIndicator, Switch) for cross-platform consistency

### 🚧 Planned Features

- **Push notifications** maybe with Firebase integration

## Project Structure

```text
lib/
├── l10n/                 # Internationalization
├── models/               # Data models
├── providers/            # Riverpod providers
├── router/               # Go Router configuration
├── services/             # API and storage services
├── viewmodels/           # MVVM ViewModels
├── views/                # UI screens
└── widgets/              # Reusable UI components
```

## Getting Started

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

## Dependencies

### Core Dependencies

- `go_router: ^16.3.0` - Navigation
- `flutter_riverpod: ^3.0.3` - State management
- `http: ^1.2.2` - API calls
- `shared_preferences: ^2.3.2` - Local storage
- `package_info_plus: ^9.0.0` - App info
- `url_launcher: ^6.3.2` - External links
- `google_fonts: ^6.2.1` - Custom typography
- `intl: ^0.20.2` - Internationalization and date formatting

### Map & Location

- `flutter_map: ^7.0.2` - Interactive maps
- `latlong2: ^0.9.1` - Geographic coordinates
- `geolocator: ^13.0.1` - Location services
- `permission_handler: ^11.3.1` - Permission management

### Data Serialization

- `json_annotation: ^4.9.0` - JSON serialization annotations
- `json_serializable: ^6.8.0` - Code generation for JSON (dev dependency)
- `build_runner: ^2.4.13` - Code generation tool (dev dependency)

### Development Tools

- `flutter_lints: ^6.0.0` - Linting rules (dev dependency)
- `flutter_launcher_icons: ^0.14.4` - App icon generation
- `flutter_native_splash: ^2.4.7` - Splash screen generation

## Contributing

This project is in active development. Contributions are welcome!
