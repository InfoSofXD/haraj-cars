import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:haraj/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';

class AppInitialization {
  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    // For web, we'll always initialize Flutter and show the HTML interface first
    if (kIsWeb) {
      print('Running Flutter app on web - will show HTML interface first');
    }

    // Initialize Supabase
    await _initializeSupabase();

    // Handle platform-specific initialization
    await _initializePlatformSpecific();
  }

  static Future<void> _initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      print('Supabase initialized successfully');
    } catch (e) {
      print('Error initializing Supabase: $e');
      // Continue app initialization even if Supabase fails
    }
  }

  static Future<void> _initializePlatformSpecific() async {
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        await _initializeMobile();
      }

      // Window Manager for Desktop
      if (Platform.isWindows || Platform.isMacOS) {
        await _initializeDesktop();
      }
    }
  }

  static Future<void> _initializeMobile() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  }

  static Future<void> _initializeDesktop() async {
    await windowManager.ensureInitialized();
    await windowManager.hide();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(650, 1050),
      minimumSize: Size(300, 768),
      center: false,
      title: 'Haraj Ohio',
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions);

    // Position
    await windowManager.setPosition(const Offset(1275, 0));
  }

  static Future<void> showDesktopWindow() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      await windowManager.show();
      await windowManager.focus();
    }
  }

  static void removeSplashScreen() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Remove splash screen immediately for mobile
      FlutterNativeSplash.remove();
    }

    // For web, remove splash screen immediately
    if (kIsWeb) {
      FlutterNativeSplash.remove();
    }
  }
}
