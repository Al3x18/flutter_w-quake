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

## Data Source

### INGV Web Services API

This application uses the **INGV (Istituto Nazionale di Geofisica e Vulcanologia)** earthquake data API:

**Base URL:** `https://webservices.ingv.it/fdsnws/event/1/query`

#### Supported Parameters

The API supports the following query parameters for filtering earthquake events:

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | string | Response format (using `geojson`) |
| `starttime` | ISO date | Start date for event search (ISO 8601 format: YYYY-MM-DD) |
| `endtime` | ISO date | End date for event search (ISO 8601 format: YYYY-MM-DD) |
| `minmagnitude` | double | Minimum earthquake magnitude |
| `minlatitude` | double | Minimum latitude (South boundary) |
| `maxlatitude` | double | Maximum latitude (North boundary) |
| `minlongitude` | double | Minimum longitude (West boundary) |
| `maxlongitude` | double | Maximum longitude (East boundary) |

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

## Features

### ✅ Implemented

- Real-time earthquake data from INGV API
- Multi-language support (English/Italian)
- Dark theme with custom styling
- Advanced filtering (geographic area, magnitude, date range)
- Statistics display with expandable cards
- Settings management with persistent storage
- MVVM architecture with Riverpod state management

### 🚧 Planned Features

- **Earthquake detail pages** with comprehensive event information
- **Interactive map view** showing earthquake locations
- **Push notifications** maybe with Firebase integration
- **Map integration** maybe with Google Maps

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

- `go_router: ^16.3.0` - Navigation
- `riverpod: ^3.0.3` - State management
- `http: ^1.2.2` - API calls
- `shared_preferences: ^2.3.2` - Local storage
- `package_info_plus: ^9.0.0` - App info
- `url_launcher: ^6.3.2` - External links

## Contributing

This project is in active development. Contributions are welcome!
