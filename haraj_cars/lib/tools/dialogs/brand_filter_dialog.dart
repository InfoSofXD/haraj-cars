import 'package:flutter/material.dart';
import '../../models/car.dart';
import 'modern_dialog_base.dart';

class BrandFilterDialog extends StatelessWidget {
  final List<Car> cars;
  final String selectedBrand;
  final Function(String) onBrandSelected;

  const BrandFilterDialog({
    Key? key,
    required this.cars,
    required this.selectedBrand,
    required this.onBrandSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brands = cars.map((car) => car.brand).toSet().toList()..sort();

    return ModernDialogBase(
      title: 'Filter by Brand',
      icon: Icons.directions_car,
      iconColor: Theme.of(context).colorScheme.primary,
      content: SizedBox(
        height: 300,
        child: ListView.builder(
          itemCount: brands.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildBrandOption(
                context,
                value: '',
                title: 'All Brands',
                subtitle: '${cars.length} cars available',
                count: cars.length,
                isSelected: selectedBrand.isEmpty,
              );
            }
            final brand = brands[index - 1];
            final carCount = cars.where((car) => car.brand == brand).length;
            return _buildBrandOption(
              context,
              value: brand,
              title: brand,
              subtitle: '$carCount cars',
              count: carCount,
              isSelected: selectedBrand == brand,
            );
          },
        ),
      ),
      actions: [
        ModernButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildBrandOption(
    BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required int count,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        onBrandSelected(value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.2),
                    colorScheme.primary.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.5)
                : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.2)
                    : colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.directions_car,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.primary.withOpacity(0.7),
                size: 20,
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : isDark
                              ? Colors.white
                              : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.2)
                    : isDark
                        ? Colors.grey[700]!.withOpacity(0.5)
                        : Colors.grey[200]!.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? colorScheme.primary
                      : isDark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 20,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: isDark ? Colors.grey[400] : Colors.grey[500],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required List<Car> cars,
    required String selectedBrand,
    required Function(String) onBrandSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => BrandFilterDialog(
        cars: cars,
        selectedBrand: selectedBrand,
        onBrandSelected: onBrandSelected,
      ),
    );
  }
}

