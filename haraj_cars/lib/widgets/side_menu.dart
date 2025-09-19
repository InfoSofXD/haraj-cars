import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tools/theme_controller.dart';

class SideMenu extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTabTapped;
  final bool isAdmin;

  const SideMenu({
    Key? key,
    required this.child,
    required this.currentIndex,
    required this.onTabTapped,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();

  static void toggle(BuildContext context) {
    ZoomDrawer.of(context)?.toggle();
  }
}

class _SideMenuState extends State<SideMenu> {
  // Settings state
  bool? themeMode;
  String selectedLanguage = 'English';
  bool useMetricUnits = true;
  bool useSARCurrency = true;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      menuScreen: _buildMenuScreen(),
      mainScreen: widget.child,
      borderRadius: 24.0,
      showShadow: true,
      angle: 0.0,
      slideWidth: MediaQuery.of(context).size.width * 0.8,
      menuBackgroundColor: colorScheme.primary,
    );
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  Widget _buildMenuScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          color: colorScheme.primary,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildMenuSection(
                        title: 'Navigation',
                        children: [
                          if (widget.isAdmin)
                            _buildMenuItem(
                              icon: Icons.dashboard,
                              title: 'Dashboard',
                              subtitle: 'Overview & Analytics',
                              isSelected: widget.currentIndex == 0,
                              onTap: () => _navigateToTab(0),
                            ),
                          _buildMenuItem(
                            icon: Icons.directions_car,
                            title: 'Cars',
                            subtitle: 'Browse & Manage Cars',
                            isSelected:
                                widget.currentIndex == (widget.isAdmin ? 1 : 0),
                            onTap: () => _navigateToTab(widget.isAdmin ? 1 : 0),
                          ),
                          _buildMenuItem(
                            icon: Icons.public,
                            title: 'Global Sites',
                            subtitle: 'External Car Websites',
                            isSelected:
                                widget.currentIndex == (widget.isAdmin ? 2 : 1),
                            onTap: () => _navigateToTab(widget.isAdmin ? 2 : 1),
                          ),
                          _buildMenuItem(
                            icon: Icons.people,
                            title: 'Community',
                            subtitle: 'User Community',
                            isSelected:
                                widget.currentIndex == (widget.isAdmin ? 3 : 2),
                            onTap: () => _navigateToTab(widget.isAdmin ? 3 : 2),
                          ),
                          _buildMenuItem(
                            icon: Icons.favorite,
                            title: 'Favorites',
                            subtitle: 'Your Saved Cars',
                            isSelected:
                                widget.currentIndex == (widget.isAdmin ? 4 : 3),
                            onTap: () => _navigateToTab(widget.isAdmin ? 4 : 3),
                          ),
                          _buildMenuItem(
                            icon: Icons.info,
                            title: 'Info',
                            subtitle: 'App Information',
                            isSelected:
                                widget.currentIndex == (widget.isAdmin ? 5 : 4),
                            onTap: () => _navigateToTab(widget.isAdmin ? 5 : 4),
                          ),
                          _buildMenuItem(
                            icon: Icons.person,
                            title: 'Account',
                            subtitle: 'Profile & Settings',
                            isSelected:
                                widget.currentIndex == (widget.isAdmin ? 6 : 5),
                            onTap: () => _navigateToTab(widget.isAdmin ? 6 : 5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildMenuSection(
                        title: 'Settings',
                        children: [
                          _buildSettingsItem(
                            icon: Icons.palette,
                            title: 'Theme',
                            subtitle: _getThemeText(),
                            onTap: _showThemeDialog,
                          ),
                          _buildSettingsItem(
                            icon: Icons.language,
                            title: 'Language',
                            subtitle: selectedLanguage,
                            onTap: _showLanguageDialog,
                          ),
                          _buildSettingsItem(
                            icon: Icons.straighten,
                            title: 'Units',
                            subtitle: useMetricUnits ? 'Kilometers' : 'Miles',
                            onTap: _showUnitsDialog,
                          ),
                          _buildSettingsItem(
                            icon: Icons.attach_money,
                            title: 'Currency',
                            subtitle: useSARCurrency ? 'SAR' : 'USD',
                            onTap: _showCurrencyDialog,
                          ),
                          _buildSettingsItem(
                            icon: notificationsEnabled
                                ? Icons.notifications
                                : Icons.notifications_off,
                            title: 'Notifications',
                            subtitle:
                                notificationsEnabled ? 'Enabled' : 'Disabled',
                            onTap: _toggleNotifications,
                            isToggle: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HARAJ . OHIO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Car Marketplace',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap();
            // The drawer will close automatically when a menu item is tapped
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isToggle = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToggle)
                  Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                        _saveSettings();
                      });
                    },
                    activeColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    inactiveThumbColor: Colors.white,
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    widget.onTabTapped(index);
  }

  String _getThemeText() {
    if (themeMode == null) return 'System';
    if (themeMode == true) return 'Dark';
    return 'Light';
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('System', null),
            _buildThemeOption('Light', false),
            _buildThemeOption('Dark', true),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String title, bool? value) {
    return ListTile(
      title: Text(title),
      leading: Radio<bool?>(
        value: value,
        groupValue: themeMode,
        onChanged: (bool? newValue) {
          setState(() {
            themeMode = newValue;
            _saveSettings();
          });
          ThemeController.instance.setThemeBool(themeMode);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'English'),
            _buildLanguageOption('العربيه', 'العربيه'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String value) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: value,
        groupValue: selectedLanguage,
        onChanged: (String? newValue) {
          setState(() {
            selectedLanguage = newValue!;
            _saveSettings();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnitsOption('Kilometers', true),
            _buildUnitsOption('Miles', false),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsOption(String title, bool value) {
    return ListTile(
      title: Text(title),
      leading: Radio<bool>(
        value: value,
        groupValue: useMetricUnits,
        onChanged: (bool? newValue) {
          setState(() {
            useMetricUnits = newValue!;
            _saveSettings();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('Saudi Riyal (SAR)', true),
            _buildCurrencyOption('US Dollar (USD)', false),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String title, bool value) {
    return ListTile(
      title: Text(title),
      leading: Radio<bool>(
        value: value,
        groupValue: useSARCurrency,
        onChanged: (bool? newValue) {
          setState(() {
            useSARCurrency = newValue!;
            _saveSettings();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
      _saveSettings();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (themeMode == null) {
      await prefs.remove('theme_mode');
    } else {
      await prefs.setBool('theme_mode', themeMode!);
    }

    await prefs.setString('selected_language', selectedLanguage);
    await prefs.setBool('use_metric_units', useMetricUnits);
    await prefs.setBool('use_sar_currency', useSARCurrency);
    await prefs.setBool('notifications_enabled', notificationsEnabled);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('theme_mode')) {
      themeMode = prefs.getBool('theme_mode');
    } else {
      themeMode = null;
    }

    selectedLanguage = prefs.getString('selected_language') ?? 'English';
    useMetricUnits = prefs.getBool('use_metric_units') ?? true;
    useSARCurrency = prefs.getBool('use_sar_currency') ?? true;
    notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
  }
}
