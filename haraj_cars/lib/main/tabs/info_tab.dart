import 'package:flutter/material.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'App Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
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
                Container(
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
                      _buildSettingItem(
                          'Notifications', Icons.notifications, true),
                      _buildSettingItem('Dark Mode', Icons.dark_mode, false),
                      _buildSettingItem(
                          'Location Services', Icons.location_on, true),
                      _buildSettingItem('Auto-sync', Icons.sync, true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildSettingItem(String title, IconData icon, bool isEnabled) {
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
            onChanged: (value) {
              // Handle setting change
            },
            activeColor: const Color(0xFF1976D2),
          ),
        ],
      ),
    );
  }
}
