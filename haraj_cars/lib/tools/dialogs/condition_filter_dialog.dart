import 'package:flutter/material.dart';
import '../../models/car.dart';
import 'modern_dialog_base.dart';

class ConditionFilterDialog extends StatefulWidget {
  final List<Car> cars;
  final String selectedCondition;
  final Function(String, RangeValues?) onConditionSelected;

  const ConditionFilterDialog({
    Key? key,
    required this.cars,
    required this.selectedCondition,
    required this.onConditionSelected,
  }) : super(key: key);

  @override
  State<ConditionFilterDialog> createState() => _ConditionFilterDialogState();
}

class _ConditionFilterDialogState extends State<ConditionFilterDialog> {
  @override
  Widget build(BuildContext context) {
    final newCarsCount = widget.cars.where((car) => car.mileage == 0).length;
    final likeNewCarsCount = widget.cars
        .where((car) => car.mileage > 0 && car.mileage < 30000)
        .length;
    final goodCarsCount = widget.cars
        .where((car) => car.mileage >= 30000 && car.mileage < 60000)
        .length;
    final fairCarsCount = widget.cars
        .where((car) => car.mileage >= 60000 && car.mileage < 100000)
        .length;
    final highMileageCarsCount =
        widget.cars.where((car) => car.mileage >= 100000).length;

    return ModernDialogBase(
      title: 'Filter by Condition',
      icon: Icons.filter_list,
      iconColor: Theme.of(context).colorScheme.primary,
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildConditionOption(
              context,
              value: '',
              title: 'All',
              subtitle: '${widget.cars.length} cars available',
              icon: Icons.all_inclusive,
              color: Colors.grey,
              count: widget.cars.length,
            ),
            const SizedBox(height: 4),
            _buildConditionOption(
              context,
              value: 'new',
              title: 'New',
              subtitle: '0 miles',
              icon: Icons.new_releases,
              color: Colors.green,
              count: newCarsCount,
            ),
            const SizedBox(height: 4),
            _buildConditionOption(
              context,
              value: 'like-new',
              title: 'Like New',
              subtitle: '0 - 30k miles',
              icon: Icons.star,
              color: Colors.blue,
              count: likeNewCarsCount,
            ),
            const SizedBox(height: 4),
            _buildConditionOption(
              context,
              value: 'good',
              title: 'Good',
              subtitle: '30k - 60k miles',
              icon: Icons.check_circle,
              color: Colors.orange,
              count: goodCarsCount,
            ),
            const SizedBox(height: 4),
            _buildConditionOption(
              context,
              value: 'fair',
              title: 'Fair',
              subtitle: '60k - 100k miles',
              icon: Icons.info,
              color: Colors.amber,
              count: fairCarsCount,
            ),
            const SizedBox(height: 4),
            _buildConditionOption(
              context,
              value: 'high-mileage',
              title: 'High Mileage',
              subtitle: '100k+ miles',
              icon: Icons.trending_up,
              color: Colors.red,
              count: highMileageCarsCount,
            ),
            const SizedBox(height: 4),
            _buildConditionOption(
              context,
              value: 'custom-range',
              title: 'Custom Range',
              subtitle: 'Select mileage range',
              icon: Icons.tune,
              color: Colors.purple,
              count: 0,
            ),
          ],
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

  Widget _buildConditionOption(
    BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = widget.selectedCondition == value;

    return InkWell(
      onTap: () {
        widget.onConditionSelected(value, null);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
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
                ? color.withOpacity(0.5)
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
                    ? color.withOpacity(0.2)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : color.withOpacity(0.7),
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? color
                          : isDark
                              ? Colors.white
                              : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
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
                    ? color.withOpacity(0.2)
                    : isDark
                        ? Colors.grey[700]!.withOpacity(0.5)
                        : Colors.grey[200]!.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? color
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
                color: color,
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
}
