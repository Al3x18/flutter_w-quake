import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/home_page.dart';
import '../views/settings_page.dart';
import '../views/settings/filters_settings_page.dart';
import '../views/settings/language_settings_page.dart';
import '../views/settings/notifications_settings_page.dart';
import '../views/settings/information_settings_page.dart';
import '../views/settings/location_settings_page.dart';
import '../views/settings/data_source_settings_page.dart';
import '../views/earthquake_detail_page.dart';

class AppRouter {
  static const String home = '/';
  static const String settings = '/settings';
  static const String filtersSettings = '/settings/filters';
  static const String languageSettings = '/settings/language';
  static const String notificationsSettings = '/settings/notifications';
  static const String informationSettings = '/settings/information';
  static const String locationSettings = '/settings/location';
  static const String dataSourceSettings = '/settings/data-source';
  static const String earthquakeDetail = '/earthquake/:id';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: filtersSettings,
        name: 'filters-settings',
        builder: (context, state) => const FiltersSettingsPage(),
      ),
      GoRoute(
        path: languageSettings,
        name: 'language-settings',
        builder: (context, state) => const LanguageSettingsPage(),
      ),
      GoRoute(
        path: notificationsSettings,
        name: 'notifications-settings',
        builder: (context, state) => const NotificationsSettingsPage(),
      ),
      GoRoute(
        path: informationSettings,
        name: 'information-settings',
        builder: (context, state) => const InformationSettingsPage(),
      ),
      GoRoute(
        path: locationSettings,
        name: 'location-settings',
        builder: (context, state) => const LocationSettingsPage(),
      ),
      GoRoute(
        path: dataSourceSettings,
        name: 'data-source-settings',
        builder: (context, state) => const DataSourceSettingsPage(),
      ),
      GoRoute(
        path: earthquakeDetail,
        name: 'earthquake-detail',
        builder: (context, state) {
          final earthquakeId = state.pathParameters['id'] ?? '';
          return EarthquakeDetailPage(earthquakeId: earthquakeId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
