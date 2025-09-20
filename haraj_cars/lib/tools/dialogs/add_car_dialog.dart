import 'package:flutter/material.dart';
import '../../screens/add_car_screen.dart';
import '../../screens/car_scraper.dart';
import 'modern_dialog_base.dart';

class AddCarDialog extends StatelessWidget {
  const AddCarDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCarDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernDialogBase(
      title: 'Add New Car',
      icon: Icons.add_circle_outline,
      iconColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Theme.of(context).colorScheme.primary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'How would you like to add a new car?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildOptionCard(
            context,
            icon: Icons.edit,
            title: 'Add Manually',
            subtitle: 'Enter car details by hand',
            onTap: () {
              Navigator.of(context).pop();
              _showManualAddCar(context);
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            context,
            icon: Icons.web,
            title: 'Scrape Car Data',
            subtitle: 'Extract data from websites',
            onTap: () {
              Navigator.of(context).pop();
              _showScrapeCarDialog(context);
            },
          ),
        ],
      ),
      actions: [
        ModernButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey[800]!.withOpacity(0.5),
                    Colors.grey[700]!.withOpacity(0.3),
                  ]
                : [
                    Colors.white.withOpacity(0.8),
                    Colors.grey[50]!.withOpacity(0.6),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : colorScheme.primary,
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
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  static void _showManualAddCar(BuildContext context) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const AddCarScreen(),
      ),
    )
        .then((result) {
      if (result == true) {
        // Car added successfully - cars tab will handle refreshing
      }
    });
  }

  static void _showScrapeCarDialog(BuildContext context) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const CarScraper(),
      ),
    )
        .then((result) {
      if (result != null && result is Map<String, dynamic>) {
        // Handle scraped car data if needed
      }
    });
  }
}
