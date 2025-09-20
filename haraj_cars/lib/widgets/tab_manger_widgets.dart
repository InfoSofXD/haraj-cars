import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../tools/Palette/theme.dart' as custom_theme;
import '../tools/theme_controller.dart';

class TabManagerWidgets {
  // Top Navigation Bar
  static Widget buildTopNavigationBar(BuildContext context,
      {VoidCallback? onAdminLogin}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[700]
            : colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HARAJ . OHIO',
              style: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                letterSpacing: 1.2,
              ),
            ),
            Row(
              children: [
                // Admin login button (hidden)
                GestureDetector(
                  onTap: onAdminLogin,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 3-dots menu button
                buildThreeDotsMenu(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Three Dots Menu
  static Widget buildThreeDotsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: colorScheme.onPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: buildSettingsPopupMenu(context),
        ),
      ),
    );
  }

  // Settings Popup Menu
  static Widget buildSettingsPopupMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: colorScheme.onPrimary.withOpacity(0.9),
      ),
      tooltip: '',
      color: Colors.transparent,
      elevation: 0,
      splashRadius: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(
        minWidth: 270,
        maxWidth: 270,
      ),
      offset: const Offset(0, 5),
      onOpened: () {
        // Don't reset language menu state - let it stay as it was
        // This allows the language submenu to remain expanded if it was expanded before
      },
      itemBuilder: (BuildContext context) => [
        // Settings menu
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? colorScheme.surface.withOpacity(0.9)
                      : custom_theme.light.shade100.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Theme Option
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]!.withOpacity(0.3)
                                  : custom_theme.light.shade100
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: Consumer<ThemeController>(
                              builder: (context, themeController, child) {
                                return StatefulBuilder(
                                  builder: (context, setInnerState) {
                                    return buildThemeOption(context,
                                        setInnerState, themeController);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Divider
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 1,
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                    // Language Option
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]!.withOpacity(0.3)
                                  : custom_theme.light.shade100
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return buildLanguageOption(
                                    context, setInnerState);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Unit of Measurement Option
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]!.withOpacity(0.3)
                                  : custom_theme.light.shade100
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return buildMeasurementOption(
                                    context, setInnerState);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Currency Option
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]!.withOpacity(0.3)
                                  : custom_theme.light.shade100
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return buildCurrencyOption(
                                    context, setInnerState);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Notification Option
                    StatefulBuilder(
                      builder: (context, setInnerState) {
                        return buildNotificationOption(context, setInnerState);
                      },
                    ),
                    // Contact Us Option
                    buildContactOption(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Bottom Navigation Bar
  static Widget buildBottomNavigationBar(
    BuildContext context, {
    required int currentIndex,
    required bool isAdmin,
    required Function(int) onTabTapped,
    VoidCallback? onAddCar,
  }) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.grey[700]!.withOpacity(0.3)
                : custom_theme.light.shade100.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : custom_theme.light.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Main navigation tabs
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Dashboard tab (admin only)
                      if (isAdmin)
                        buildBottomNavItem(context, Icons.dashboard, 0,
                            currentIndex == 0, onTabTapped),
                      // Cars tab
                      buildBottomNavItem(
                          context,
                          Icons.directions_car,
                          isAdmin ? 1 : 0,
                          currentIndex == (isAdmin ? 1 : 0),
                          onTabTapped),
                      // Global Sites tab
                      buildBottomNavItem(context, Icons.public, isAdmin ? 2 : 1,
                          currentIndex == (isAdmin ? 2 : 1), onTabTapped),
                      // Community tab
                      buildBottomNavItem(context, Icons.groups, isAdmin ? 3 : 2,
                          currentIndex == (isAdmin ? 3 : 2), onTabTapped),
                      // Favorites tab
                      buildBottomNavItem(
                          context,
                          Icons.favorite,
                          isAdmin ? 4 : 3,
                          currentIndex == (isAdmin ? 4 : 3),
                          onTabTapped),
                      // Calculator tab
                      buildBottomNavItem(
                          context,
                          Icons.calculate,
                          isAdmin ? 5 : 4,
                          currentIndex == (isAdmin ? 5 : 4),
                          onTabTapped),
                      // Info tab
                      buildBottomNavItem(context, Icons.info, isAdmin ? 6 : 5,
                          currentIndex == (isAdmin ? 6 : 5), onTabTapped),
                      // Account tab
                      buildBottomNavItem(context, Icons.person, isAdmin ? 7 : 6,
                          currentIndex == (isAdmin ? 7 : 6), onTabTapped),
                    ],
                  ),
                ),
                // Admin add button (only show in cars tab when admin)
                if (isAdmin && currentIndex == 1) ...[
                  const SizedBox(width: 16),
                  buildAdminAddButton(context, onAddCar),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bottom Navigation Item
  static Widget buildBottomNavItem(BuildContext context, IconData icon,
      int index, bool isActive, Function(int) onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // Admin Add Button
  static Widget buildAdminAddButton(BuildContext context, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.8),
              const Color(0xFF2E7D32).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF81C784),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // Theme Option
  static Widget buildThemeOption(BuildContext context,
      StateSetter setInnerState, ThemeController themeController) {
    final currentThemeMode = themeController.themeMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () {
            // This will be handled by the parent
          },
          leading: Icon(
            currentThemeMode == ThemeMode.system
                ? Icons.settings
                : currentThemeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
            color: Colors.white,
          ),
          title: const Text(
            'Theme',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  currentThemeMode == ThemeMode.system
                      ? 'SYS'
                      : currentThemeMode == ThemeMode.dark
                          ? 'DARK'
                          : 'LIGHT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Language Option
  static Widget buildLanguageOption(
      BuildContext context, StateSetter setInnerState) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            Icons.language,
            color: Colors.white,
          ),
          title: Text(
            'Language',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Measurement Option
  static Widget buildMeasurementOption(
      BuildContext context, StateSetter setInnerState) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            Icons.straighten,
            color: Colors.white,
          ),
          title: Text(
            'Unit',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'KM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Currency Option
  static Widget buildCurrencyOption(
      BuildContext context, StateSetter setInnerState) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            Icons.attach_money,
            color: Colors.white,
          ),
          title: Text(
            'Currency',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Notification Option
  static Widget buildNotificationOption(
      BuildContext context, StateSetter setInnerState) {
    return InkWell(
      onTap: () {
        // This will be handled by the parent
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: const ListTile(
          leading: Icon(
            Icons.notifications,
            color: Colors.white,
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Switch(
            value: true,
            onChanged: null,
            activeColor: Colors.white,
            inactiveTrackColor: Colors.white,
            inactiveThumbColor: Colors.white,
          ),
        ),
      ),
    );
  }

  // Contact Option
  static Widget buildContactOption(BuildContext context) {
    return InkWell(
      onTap: () {
        // This will be handled by the parent
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: const ListTile(
          leading: Icon(
            Icons.contact_support,
            color: Colors.white,
          ),
          title: Text(
            'Contact Us',
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
