import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../tools/Palette/theme.dart' as custom_theme;

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  // Settings state
  bool? themeMode; // null = system, true = dark, false = light
  String selectedLanguage = 'English';
  bool useMetricUnits = true; // true = km, false = miles
  bool useSARCurrency = true; // true = SAR, false = USD
  bool notificationsEnabled = true; // true = enabled, false = disabled

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    if (prefs.containsKey('theme_mode')) {
      themeMode = prefs.getBool('theme_mode');
    } else {
      themeMode = null; // Default to system
    }

    // Load language
    selectedLanguage = prefs.getString('selected_language') ?? 'English';

    // Load measurement units
    useMetricUnits = prefs.getBool('use_metric_units') ?? true; // Default to km

    // Load currency
    useSARCurrency =
        prefs.getBool('use_sar_currency') ?? true; // Default to SAR

    // Load notifications
    notificationsEnabled =
        prefs.getBool('notifications_enabled') ?? true; // Default to enabled

    // Update UI if widget is mounted
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Save theme mode
    if (themeMode == null) {
      await prefs.remove('theme_mode');
    } else {
      await prefs.setBool('theme_mode', themeMode!);
    }

    // Save language
    await prefs.setString('selected_language', selectedLanguage);

    // Save measurement units
    await prefs.setBool('use_metric_units', useMetricUnits);

    // Save currency
    await prefs.setBool('use_sar_currency', useSARCurrency);

    // Save notifications
    await prefs.setBool('notifications_enabled', notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? colorScheme.background
          : Colors.white,
      appBar: AppBar(
        title: Text(
          'App Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.brightness == Brightness.dark
            ? Colors.grey[700]
            : colorScheme.surfaceVariant,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            'About Haraj Cars',
            'Find the best deals on new and used cars in the USA. Browse thousands of listings from trusted dealers and private sellers.',
            Icons.car_rental,
          ),
          _buildInfoCard(
            'Features',
            '• Search and filter cars by brand, year, price\n• Save your favorite cars\n• Browse global car marketplaces\n• Detailed car information and photos',
            Icons.star,
          ),
          _buildInfoCard(
            'Contact Us',
            'Email: support@harajcars.com\nPhone: +1 (555) 123-4567\nWebsite: www.harajcars.com',
            Icons.contact_support,
          ),
          _buildInfoCard(
            'Version',
            'Version 1.0.0\nBuild 2024.1\nLast updated: January 2024',
            Icons.info,
          ),
          const SizedBox(height: 20),
          // Settings Section
          _buildSettingsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildThemeSetting(),
          const SizedBox(height: 8),
          _buildLanguageSetting(),
          const SizedBox(height: 8),
          _buildMeasurementSetting(),
          const SizedBox(height: 8),
          _buildCurrencySetting(),
          const SizedBox(height: 8),
          _buildNotificationSetting(),
        ],
      ),
    );
  }

  Widget _buildThemeSetting() {
    return _buildSettingItem(
      'Theme',
      Icons.palette,
      themeMode == null
          ? 'System'
          : themeMode == true
              ? 'Dark'
              : 'Light',
      () {
        setState(() {
          // Cycle through: null (system) -> false (light) -> true (dark) -> null (system)
          if (themeMode == null) {
            themeMode = false; // Light
          } else if (themeMode == false) {
            themeMode = true; // Dark
          } else {
            themeMode = null; // System
          }
          _saveSettings();
        });
      },
    );
  }

  Widget _buildLanguageSetting() {
    return _buildSettingItem(
      'Language',
      Icons.language,
      selectedLanguage,
      () {
        setState(() {
          selectedLanguage =
              selectedLanguage == 'English' ? 'العربيه' : 'English';
          _saveSettings();
        });
      },
    );
  }

  Widget _buildMeasurementSetting() {
    return _buildSettingItem(
      'Unit of Measurement',
      Icons.straighten,
      useMetricUnits ? 'Kilometers (km)' : 'Miles (mi)',
      () {
        setState(() {
          useMetricUnits = !useMetricUnits;
          _saveSettings();
        });
      },
    );
  }

  Widget _buildCurrencySetting() {
    return _buildSettingItem(
      'Currency',
      Icons.attach_money,
      useSARCurrency ? 'Saudi Riyal (SAR)' : 'US Dollar (USD)',
      () {
        setState(() {
          useSARCurrency = !useSARCurrency;
          _saveSettings();
        });
      },
    );
  }

  Widget _buildNotificationSetting() {
    return _buildSettingItemWithSwitch(
      'Notifications',
      Icons.notifications,
      notificationsEnabled,
      (value) {
        setState(() {
          notificationsEnabled = value;
          _saveSettings();
        });
      },
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? colorScheme.primary.withOpacity(0.1)
                  : custom_theme.light.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                    fontFamily: 'Tajawal',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      String title, IconData icon, String value, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Tajawal',
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey[600],
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey[400],
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemWithSwitch(String title, IconData icon,
      bool isEnabled, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.7)
                : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Tajawal',
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: theme.brightness == Brightness.dark
                ? Colors.white
                : colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
