import 'package:flutter/material.dart';
import '../../models/car.dart';
import '../../supabase/supabase_service.dart';
import 'modern_dialog_base.dart';

class StatusUpdateDialog extends StatefulWidget {
  final Car car;
  final Function(bool) onStatusUpdated;

  const StatusUpdateDialog({
    Key? key,
    required this.car,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  State<StatusUpdateDialog> createState() => _StatusUpdateDialogState();
}

class _StatusUpdateDialogState extends State<StatusUpdateDialog> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  late int _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.car.status;
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update only the status field directly in the database
      final success = await _supabaseService.updateCarStatus(
          widget.car.carId, _currentStatus);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onStatusUpdated(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Car status updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update car status. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernDialogBase(
      title: 'Update Car Status',
      icon: Icons.edit,
      iconColor: Theme.of(context).colorScheme.primary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Car info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.car.computedTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Status selection
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.update,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Select Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatusOption(
                    1, 'Available', Colors.green, Icons.check_circle),
                const SizedBox(height: 8),
                _buildStatusOption(
                    2, 'Unavailable', Colors.orange, Icons.pause_circle),
                const SizedBox(height: 8),
                _buildStatusOption(3, 'Auction', Colors.blue, Icons.gavel),
                const SizedBox(height: 8),
                _buildStatusOption(4, 'Sold', Colors.red, Icons.sell),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ModernButton(
          text: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        ModernButton(
          text: _isLoading ? 'Updating...' : 'Update Status',
          isPrimary: true,
          icon: Icons.update,
          onPressed: _isLoading ? null : _updateStatus,
          width: 140,
        ),
      ],
    );
  }

  Widget _buildStatusOption(
      int statusValue, String statusText, Color statusColor, IconData icon) {
    final isSelected = _currentStatus == statusValue;

    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _currentStatus = statusValue;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? statusColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? statusColor
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? statusColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  color: isSelected
                      ? statusColor
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: statusColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
