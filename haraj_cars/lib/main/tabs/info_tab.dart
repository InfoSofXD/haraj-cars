import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class InfoTab extends StatefulWidget {
  const InfoTab({Key? key}) : super(key: key);

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
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
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Content (full screen, content scrolls under floating title)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 100, // Space for floating title
                    bottom: 110, // Space for floating bottom nav bar
                  ),
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
              ),
            ],
          ),

          // Floating Title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingTitle(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTitle() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2196F3).withOpacity(0.3),
                  const Color(0xFF1976D2).withOpacity(0.4),
                  const Color(0xFF1565C0).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF42A5F5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'App Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1976D2),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemWithSwitch(String title, IconData icon,
      bool isEnabled, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: const Color(0xFF1976D2),
          ),
        ],
      ),
    );
  }
}
