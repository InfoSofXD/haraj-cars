import 'package:flutter/material.dart';
import '../../models/car.dart';
import 'modern_dialog_base.dart';

class YearFilterDialog extends StatelessWidget {
  final List<Car> cars;
  final String selectedYear;
  final Function(String) onYearSelected;

  const YearFilterDialog({
    Key? key,
    required this.cars,
    required this.selectedYear,
    required this.onYearSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get unique years from actual car data, sorted descending
    final years = cars.map((car) => car.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final yearStrings = years.map((year) => year.toString()).toList();

    return ModernDialogBase(
      title: 'Filter by Year',
      icon: Icons.calendar_today,
      iconColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Theme.of(context).colorScheme.primary,
      content: SizedBox(
        height: 300,
        child: ListView.builder(
          itemCount: yearStrings.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildYearOption(
                context,
                value: '',
                title: 'All Years',
                subtitle: '${cars.length} cars available',
                count: cars.length,
                isSelected: selectedYear.isEmpty,
              );
            }
            final year = yearStrings[index - 1];
            final carCount =
                cars.where((car) => car.year.toString() == year).length;
            return _buildYearOption(
              context,
              value: year,
              title: year,
              subtitle: '$carCount cars',
              count: carCount,
              isSelected: selectedYear == year,
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

  Widget _buildYearOption(
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
        onYearSelected(value);
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
                Icons.calendar_today,
                color: isSelected
                    ? (isDark ? Colors.white : colorScheme.primary)
                    : (isDark
                        ? Colors.grey[300]
                        : colorScheme.primary.withOpacity(0.7)),
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
                          ? (isDark ? Colors.white : colorScheme.primary)
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
                      ? (isDark ? Colors.white : colorScheme.primary)
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
                color: isDark ? Colors.white : colorScheme.primary,
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
    required String selectedYear,
    required Function(String) onYearSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => YearFilterDialog(
        cars: cars,
        selectedYear: selectedYear,
        onYearSelected: onYearSelected,
      ),
    );
  }
}
