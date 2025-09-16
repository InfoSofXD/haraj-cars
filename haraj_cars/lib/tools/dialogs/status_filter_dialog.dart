import 'package:flutter/material.dart';
import '../../models/car.dart';
import 'modern_dialog_base.dart';

class StatusFilterDialog extends StatelessWidget {
  final List<Car> cars;
  final int selectedStatus;
  final Function(int) onStatusSelected;

  const StatusFilterDialog({
    Key? key,
    required this.cars,
    required this.selectedStatus,
    required this.onStatusSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernDialogBase(
      title: 'Filter by Status',
      icon: Icons.info,
      iconColor: Theme.of(context).colorScheme.primary,
      content: SizedBox(
        height: 300,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildStatusOption(
                context,
                value: 0,
                title: 'All Status',
                subtitle: '${cars.length} cars available',
                count: cars.length,
                isSelected: selectedStatus == 0,
                color: Colors.grey,
                icon: Icons.all_inclusive,
              );
            }

            final statusValue = index;
            final statusText = statusValue == 1
                ? 'Available'
                : statusValue == 2
                    ? 'Unavailable'
                    : statusValue == 3
                        ? 'Auction'
                        : 'Sold';
            final carCount =
                cars.where((car) => car.status == statusValue).length;
            final statusColor = statusValue == 1
                ? Colors.green
                : statusValue == 2
                    ? Colors.orange
                    : statusValue == 3
                        ? Colors.blue
                        : Colors.red;
            final statusIcon = statusValue == 1
                ? Icons.check_circle
                : statusValue == 2
                    ? Icons.pause_circle
                    : statusValue == 3
                        ? Icons.gavel
                        : Icons.sell;

            return _buildStatusOption(
              context,
              value: statusValue,
              title: statusText,
              subtitle: '$carCount cars',
              count: carCount,
              isSelected: selectedStatus == statusValue,
              color: statusColor,
              icon: statusIcon,
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

  Widget _buildStatusOption(
    BuildContext context, {
    required int value,
    required String title,
    required String subtitle,
    required int count,
    required bool isSelected,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        onStatusSelected(value);
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? color
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
                    ? color.withOpacity(0.2)
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

  static void show(
    BuildContext context, {
    required List<Car> cars,
    required int selectedStatus,
    required Function(int) onStatusSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => StatusFilterDialog(
        cars: cars,
        selectedStatus: selectedStatus,
        onStatusSelected: onStatusSelected,
      ),
    );
  }
}
