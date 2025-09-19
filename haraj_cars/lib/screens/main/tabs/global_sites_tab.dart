import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../main/tabs/extra_options/outside_site_card.dart';
import '../../../../tools/Palette/theme.dart' as custom_theme;

class GlobalSitesTab extends StatelessWidget {
  const GlobalSitesTab({Key? key}) : super(key: key);

  final List<Map<String, String>> carSites = const [
    {
      'name': 'AutoTrader',
      'url': 'https://www.autotrader.com',
      'description': 'Find new and used cars for sale',
      'icon': '🚗',
    },
    {
      'name': 'Cars.com',
      'url': 'https://www.cars.com',
      'description': 'Shop new and used cars',
      'icon': '🚙',
    },
    {
      'name': 'CarMax',
      'url': 'https://www.carmax.com',
      'description': 'Buy and sell used cars',
      'icon': '🚘',
    },
    {
      'name': 'CarGurus',
      'url': 'https://www.cargurus.com',
      'description': 'Find great deals on new and used cars',
      'icon': '🔍',
    },
    {
      'name': 'Edmunds',
      'url': 'https://www.edmunds.com',
      'description': 'Car reviews, pricing, and research',
      'icon': '📊',
    },
    {
      'name': 'Kelley Blue Book',
      'url': 'https://www.kbb.com',
      'description': 'Car values and reviews',
      'icon': '📖',
    },
    {
      'name': 'TrueCar',
      'url': 'https://www.truecar.com',
      'description': 'New and used car pricing',
      'icon': '💰',
    },
    {
      'name': 'Vroom',
      'url': 'https://www.vroom.com',
      'description': 'Buy and sell cars online',
      'icon': '💻',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: theme.brightness == Brightness.dark
          ? colorScheme.background
          : Colors.white,
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Sites List (full screen, content scrolls under floating title)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 100, // Space for floating title to hover above
                    bottom: 110, // Space for floating bottom nav bar
                  ),
                  itemCount: carSites.length,
                  itemBuilder: (context, index) {
                    final site = carSites[index];
                    return SiteCard(
                      name: site['name']!,
                      url: site['url']!,
                      description: site['description']!,
                      icon: site['icon']!,
                    );
                  },
                ),
              ),
            ],
          ),

          // Floating Title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingTitle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[700]!.withOpacity(0.3)
                  : custom_theme.light.shade100.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
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
            child: Row(
              children: [
                Icon(
                  Icons.public,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Global Car Marketplaces',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : colorScheme.onSurface,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
