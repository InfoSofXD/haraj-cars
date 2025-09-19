import 'package:flutter/material.dart';
import '../../../../tools/Palette/theme.dart' as custom_theme;

class AdminWorkerSidebar extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final int selectedIndex;

  const AdminWorkerSidebar({
    Key? key,
    required this.onNavigateToTab,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<AdminWorkerSidebar> createState() => _AdminWorkerSidebarState();
}

class _AdminWorkerSidebarState extends State<AdminWorkerSidebar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface
            : Colors.white,
        border: Border(
          right: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : custom_theme.light.shade300,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(theme, colorScheme),
          
          // Navigation Items
          Expanded(
            child: _buildNavigationItems(theme, colorScheme),
          ),
          
          // Footer
          _buildFooter(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : custom_theme.light.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    Text(
                      'Management Dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[600],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(ThemeData theme, ColorScheme colorScheme) {
    final navigationItems = [
      _NavigationItem(
        icon: Icons.home,
        title: 'Home',
        subtitle: 'Main cars screen',
        index: 0,
      ),
      _NavigationItem(
        icon: Icons.directions_car,
        title: 'Cars Management',
        subtitle: 'View, edit & add cars',
        index: 1,
      ),
      _NavigationItem(
        icon: Icons.people,
        title: 'Workers',
        subtitle: 'Track & manage workers',
        index: 2,
      ),
      _NavigationItem(
        icon: Icons.person_outline,
        title: 'Clients',
        subtitle: 'Manage client accounts',
        index: 3,
      ),
      _NavigationItem(
        icon: Icons.analytics,
        title: 'Analytics',
        subtitle: 'View reports & insights',
        index: 4,
      ),
      _NavigationItem(
        icon: Icons.description,
        title: 'System Logs',
        subtitle: 'Track all system actions',
        index: 5,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: navigationItems.length,
      itemBuilder: (context, index) {
        final item = navigationItems[index];
        final isSelected = widget.selectedIndex == item.index;
        
        return _buildNavigationItem(
          item: item,
          isSelected: isSelected,
          theme: theme,
          colorScheme: colorScheme,
        );
      },
    );
  }

  Widget _buildNavigationItem({
    required _NavigationItem item,
    required bool isSelected,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onNavigateToTab(item.index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? (theme.brightness == Brightness.dark
                      ? Colors.red.withOpacity(0.1)
                      : Colors.red.withOpacity(0.05))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.red.withOpacity(0.1)
                        : (theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? Colors.red
                        : (theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[600]),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.red
                              : (theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : colorScheme.onSurface),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.red.withOpacity(0.7)
                              : (theme.brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.grey[600]),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : custom_theme.light.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Quick Stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[800]?.withOpacity(0.5)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Status: Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[700],
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Version Info
          Text(
            'Haraj Cars Admin v1.0',
            style: TextStyle(
              fontSize: 10,
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey[500],
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final int index;

  _NavigationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.index,
  });
}
