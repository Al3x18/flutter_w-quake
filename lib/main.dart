import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'providers/earthquake_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'W-Quake',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: Locale(languageState.currentLanguage),
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('it')],
      theme: ThemeData.dark().copyWith(
        // Completely black theme
        scaffoldBackgroundColor: Colors.black,
        // General font for the entire app
        textTheme: GoogleFonts.titilliumWebTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.titilliumWeb(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[800]!, width: 1),
          ),
        ),
        colorScheme: ColorScheme.dark(primary: Colors.white, secondary: Colors.grey[200]!, surface: Colors.black, onPrimary: Colors.black, onSecondary: Colors.black, onSurface: Colors.white),
      ),
    );
  }
}
