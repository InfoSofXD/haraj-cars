import 'package:flutter/material.dart';
import 'dart:ui';
import '../tools/cards/site_card.dart';

class GlobalSitesScreen extends StatelessWidget {
  const GlobalSitesScreen({Key? key}) : super(key: key);

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

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? colorScheme.background
          : Colors.white,
      appBar: AppBar(
        title: Text(
          'Global Car Marketplaces',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
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
    );
  }
}
