import 'package:flutter/material.dart';
import '../../domain/models/log_entry.dart';

class LogFilterDialog extends StatefulWidget {
  final LogFilter? currentFilter;

  const LogFilterDialog({
    Key? key,
    this.currentFilter,
  }) : super(key: key);

  @override
  State<LogFilterDialog> createState() => _LogFilterDialogState();
}

class _LogFilterDialogState extends State<LogFilterDialog> {
  LogLevel? _selectedLevel;
  LogAction? _selectedAction;
  String? _selectedUserRole;
  String? _selectedResourceType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.currentFilter != null) {
      _selectedLevel = widget.currentFilter!.level;
      _selectedAction = widget.currentFilter!.action;
      _selectedUserRole = widget.currentFilter!.userRole;
      _selectedResourceType = widget.currentFilter!.resourceType;
      _startDate = widget.currentFilter!.startDate;
      _endDate = widget.currentFilter!.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Filter Logs'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Log Level Filter
              Text(
                'Log Level',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: LogLevel.values.map((level) {
                  final isSelected = _selectedLevel == level;
                  return FilterChip(
                    label: Text(level.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLevel = selected ? level : null;
                      });
                    },
                    selectedColor: _getLevelColor(level).withOpacity(0.2),
                    checkmarkColor: _getLevelColor(level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Action Filter
              Text(
                'Action Type',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<LogAction>(
                value: _selectedAction,
                decoration: InputDecoration(
                  hintText: 'All Actions',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                items: [
                  const DropdownMenuItem<LogAction>(
                    value: null,
                    child: Text('All Actions'),
                  ),
                  ...LogAction.values.map((action) {
                    return DropdownMenuItem<LogAction>(
                      value: action,
                      child: Row(
                        children: [
                          Text(action.icon),
                          const SizedBox(width: 8),
                          Text(action.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAction = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // User Role Filter
              Text(
                'User Role',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedUserRole,
                decoration: InputDecoration(
                  hintText: 'All Roles',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Roles'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Super Admin',
                    child: Text('Super Admin'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Worker',
                    child: Text('Worker'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Client',
                    child: Text('Client'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedUserRole = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Resource Type Filter
              Text(
                'Resource Type',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedResourceType,
                decoration: InputDecoration(
                  hintText: 'All Types',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Types'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'car',
                    child: Text('Car'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'user',
                    child: Text('User'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'worker',
                    child: Text('Worker'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'favorite',
                    child: Text('Favorite'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedResourceType = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date Range Filter
              Text(
                'Date Range',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Start Date',
                          style: TextStyle(
                            color: _startDate != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('to'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'End Date',
                          style: TextStyle(
                            color: _endDate != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear'),
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now().subtract(const Duration(days: 30)))
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedLevel = null;
      _selectedAction = null;
      _selectedUserRole = null;
      _selectedResourceType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    final filter = LogFilter(
      level: _selectedLevel,
      action: _selectedAction,
      userRole: _selectedUserRole,
      resourceType: _selectedResourceType,
      startDate: _startDate,
      endDate: _endDate,
    );

    Navigator.of(context).pop(filter);
  }

  Color _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.debug:
        return Colors.grey;
    }
  }
}
