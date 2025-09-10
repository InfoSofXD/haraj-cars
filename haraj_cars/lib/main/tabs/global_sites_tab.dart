import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
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
                    return _buildSiteCard(site);
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
                'Global Car Marketplaces',
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

  Widget _buildSiteCard(Map<String, String> site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              site['icon']!,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          site['name']!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        subtitle: Text(
          site['description']!,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Tajawal',
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF1976D2),
        ),
        onTap: () => _launchURL(site['url']!),
      ),
    );
  }
}
