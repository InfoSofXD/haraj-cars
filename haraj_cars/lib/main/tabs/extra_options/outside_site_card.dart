import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../../tools/Palette/theme.dart' as custom_theme;

class SiteCard extends StatelessWidget {
  final String name;
  final String url;
  final String description;
  final String icon;

  const SiteCard({
    Key? key,
    required this.name,
    required this.url,
    required this.description,
    required this.icon,
  }) : super(key: key);

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(2),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? colorScheme.primary.withOpacity(0.1)
                : custom_theme.light.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.7)
                : Colors.grey[600],
            fontFamily: 'Tajawal',
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : colorScheme.primary,
        ),
        onTap: () => _launchURL(url),
      ),
    );
  }
}
