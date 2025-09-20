import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:haraj/main/tab_manger.dart';
import 'package:haraj/tools/app_initialization.dart';
import 'package:haraj/tools/language/app_localizations.dart';
import 'package:haraj/tools/language/language_provider.dart';
import 'package:haraj/tools/splash_screen.dart';
import 'package:haraj/tools/window_frame.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/intro.dart';
import 'auth/sing_manger.dart';
import 'tools/theme_controller.dart';
import 'tools/Palette/theme.dart' as custom_theme;
import 'tools/calculator_viewmodel.dart';

void main() async {
  // Initialize app
  await AppInitialization.initializeApp();

  // Initialize translations
  await EasyLocalization.ensureInitialized();

  // Initialize theme controller and load saved theme
  final themeController = ThemeController.instance;
  await themeController.loadFromPrefs();

  // Language Provider
  final languageProvider = LanguageProvider();
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLanguage = prefs.getString('languageA');
    if (savedLanguage != null) {
      languageProvider.setLanguage(savedLanguage);
    }
  } catch (e) {
    print('Error loading language preferences: $e');
  }

  // Completer
  final completer = Completer<void>();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageProvider>(
            create: (_) => languageProvider,
          ),
          ChangeNotifierProvider<CalculatorViewModel>(
            create: (_) => CalculatorViewModel(),
          ),
          ChangeNotifierProvider<ThemeController>(
            create: (_) => themeController,
          ),
        ],
        child: MainApp(onFirstFrameRendered: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }),
      ),
    ),
  );

  // Show window only after app is initialized and first frame is rendered (desktop only)
  await AppInitialization.showDesktopWindow();
}

class MainApp extends StatefulWidget {
  final VoidCallback? onFirstFrameRendered;

  const MainApp({super.key, this.onFirstFrameRendered});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_onThemeChanged);

    // Call onFirstFrameRendered callback after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFirstFrameRendered?.call();
    });
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('Building harajApp - Web: $kIsWeb');

    final controller = Provider.of<ThemeController>(context);

    // Material App
    return MaterialApp(
      title: 'Haraj Ohio',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      // Force LTR
      builder: (context, child) {
        Widget wrappedChild = Directionality(
          textDirection: ui.TextDirection.ltr,
          child: !kIsWeb && (Platform.isWindows || Platform.isMacOS)
              ? ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(
                    scrollbars: false,
                  ),
                  child: child ?? Container(),
                )
              : child ?? Container(),
        );

        // Apply custom window frame on Windows
        if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
          return CustomWindowFrame(
            child: wrappedChild,
          );
        }

        return wrappedChild;
      },
      localizationsDelegates:
          context.localizationDelegates + [AppLocalizations.delegate],
      supportedLocales: context.supportedLocales,

      themeMode: controller.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: custom_theme.light,
          onPrimary: Colors.white,
          secondary: custom_theme.light.shade300,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: const Color(0xFF1565C0),
          onBackground: Colors.white,
          surface: Colors.white.withOpacity(0.1),
          onSurface: Colors.white,
          surfaceVariant: Colors.white.withOpacity(0.2),
          onSurfaceVariant: Colors.white,
          outline: Colors.white.withOpacity(0.3),
          shadow: Colors.black,
          primaryContainer: custom_theme.light.shade400,
        ),
        fontFamily: 'Tajawal',
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: custom_theme.dark,
          onPrimary: Colors.white,
          secondary: custom_theme.dark.shade300,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: const Color(0xFF424242),
          onBackground: Colors.white,
          surface: Colors.white.withOpacity(0.1),
          onSurface: Colors.white,
          surfaceVariant: Colors.white.withOpacity(0.2),
          onSurfaceVariant: Colors.white,
          outline: Colors.white.withOpacity(0.3),
          shadow: Colors.black,
          primaryContainer: custom_theme.dark.shade300,
        ),
        fontFamily: 'Tajawal',
        useMaterial3: false,
      ),
      // Screens
      initialRoute:
          (Platform.isAndroid || Platform.isIOS) ? '/initial' : '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/initial': (context) => const IntroScreen(),
        '/sign_manager': (context) => const SignManagerScreen(),
        '/tab_manger': (context) => const TabMangerScreen(),
      },
    );
  }
}
