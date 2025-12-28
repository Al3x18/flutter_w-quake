import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:w_quake/providers/first_launch_provider.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'providers/language_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageAsync = ref.watch(languageProvider);
    final locale = languageAsync.value?.currentLocale ?? const Locale('en');

    // Only for development purposes: Reset first launch to true to show the welcome screen again
    //final firstLaunchAsync = ref.read(firstLaunchProvider.notifier);
    //firstLaunchAsync.reset();

    return MaterialApp.router(
      title: 'W-Quake',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      locale: locale,
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('it')],
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,

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
