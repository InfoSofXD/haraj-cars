import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../models/car.dart';
import '../../../../tools/Palette/theme.dart' as custom_theme;

class CarCard extends StatelessWidget {
  final Car car;
  final bool isFavorite;
  final bool isAdmin;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStatusUpdate;

  const CarCard({
    Key? key,
    required this.car,
    this.isFavorite = false,
    this.isAdmin = false,
    this.onTap,
    this.onToggleFavorite,
    this.onEdit,
    this.onDelete,
    this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : custom_theme.light.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.2)
                    : custom_theme.light.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image
                _buildCarImage(colorScheme),

                // Car Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          car.computedTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : custom_theme.light.shade800,
                            fontFamily: 'Tajawal',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Details row - 3 columns
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildDetailColumn(
                                  Icons.calendar_today,
                                  car.year.toString(),
                                  colorScheme,
                                  theme,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDetailColumn(
                                  Icons.speed,
                                  '${car.mileage} mi',
                                  colorScheme,
                                  theme,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDetailColumn(
                                  Icons.settings,
                                  car.transmission,
                                  colorScheme,
                                  theme,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price and View Details button row
                        _buildPriceAndDetailsRow(colorScheme, theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarImage(ColorScheme colorScheme) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Stack(
        children: [
          // Car image
          car.mainImage != null && car.mainImage!.isNotEmpty
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    car.mainImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage(colorScheme);
                    },
                  ),
                )
              : _buildPlaceholderImage(colorScheme),

          // Heart button in top right
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onToggleFavorite,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isFavorite
                      ? Colors.red.withOpacity(0.35)
                      : Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isFavorite ? Colors.red : Colors.white,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),

          // Status indicator in bottom left
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: car.statusColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: car.statusColor,
                  width: 0.5,
                ),
              ),
              child: Text(
                car.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.directions_car,
        size: 48,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildDetailColumn(
      IconData icon, String text, ColorScheme colorScheme, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.8)
              : custom_theme.light.shade600,
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.9)
                : custom_theme.light.shade700,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPriceAndDetailsRow(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      children: [
        // Price
        Text(
          '\$${car.price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00E676),
            fontFamily: 'Tajawal',
          ),
        ),
        const Spacer(),

        // Admin buttons
        if (isAdmin) ...[
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.edit,
                size: 16,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onStatusUpdate,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.info,
                size: 16,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.delete,
                size: 16,
                color: Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // View Details button
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Tajawal',
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Extension to compute car title
extension CarExtension on Car {
  String get computedTitle {
    return '$year $brand $model';
  }
}
