import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'config/app_theme.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'screens/main_scaffold.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await MobileAds.instance.initialize();
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  
  await StorageService().initialize();
  await TtsService().initialize();
  
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('app_locale') ?? 'en';
  
  runApp(
    ProviderScope(
      child: EchoApp(initialLocaleCode: savedLocale),
    ),
  );
}

class EchoApp extends ConsumerWidget {
  final String initialLocaleCode;

  const EchoApp({super.key, required this.initialLocaleCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(localeProvider).languageCode != initialLocaleCode) {
        Future.microtask(() {
          ref.read(localeProvider.notifier).state = Locale(initialLocaleCode);
        });
      }
    });
    
    return MaterialApp(
      title: 'Echo AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('bn'),
      ],
      home: const MainScaffold(),
      routes: {
        '/': (context) => const MainScaffold(),
      },
    );
  }
}