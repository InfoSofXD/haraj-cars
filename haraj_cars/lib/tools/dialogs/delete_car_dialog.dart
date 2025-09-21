import 'package:flutter/material.dart';
import '../../models/car.dart';
import 'modern_dialog_base.dart';

class DeleteCarDialog extends StatelessWidget {
  final Car car;
  final VoidCallback? onConfirm;

  const DeleteCarDialog({
    Key? key,
    required this.car,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernDialogBase(
      title: 'Delete Car',
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This action cannot be undone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Are you sure you want to delete this car?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]!.withOpacity(0.3)
                  : Colors.grey[100]!.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    car.computedTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ModernButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ModernButton(
          text: 'Delete',
          isDestructive: true,
          icon: Icons.delete,
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context, Car car) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteCarDialog(car: car),
    );
  }
}
