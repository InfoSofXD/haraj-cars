import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase/supabase_config.dart';
import 'auth/intro.dart';
import 'tools/theme_controller.dart';
import 'tools/Palette/theme.dart' as custom_theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Preload theme from shared preferences before running the app
  await ThemeController.instance.loadFromPrefs();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_onThemeChanged);
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
    final controller = ThemeController.instance;
    return MaterialApp(
      title: 'Haraj Cars',
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
      home: const IntroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
