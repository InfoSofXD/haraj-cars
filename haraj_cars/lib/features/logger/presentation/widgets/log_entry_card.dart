import 'package:flutter/material.dart';
import '../../domain/models/log_entry.dart';

class LogEntryCard extends StatelessWidget {
  final LogEntry logEntry;
  final VoidCallback? onTap;

  const LogEntryCard({
    Key? key,
    required this.logEntry,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Action Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getActionColor(logEntry.action).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    logEntry.action.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action and Level
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            logEntry.action.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelColor(logEntry.level).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            logEntry.level.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getLevelColor(logEntry.level),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Message
                    Text(
                      logEntry.message,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // User and Time
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          logEntry.userName ?? 'System',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(logEntry.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),

                    // Resource info if available
                    if (logEntry.resourceType != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getResourceIcon(logEntry.resourceType!),
                            size: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${logEntry.resourceType}${logEntry.resourceId != null ? ' #${logEntry.resourceId}' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActionColor(LogAction action) {
    switch (action) {
      case LogAction.carCreated:
      case LogAction.carUpdated:
      case LogAction.carViewed:
        return Colors.blue;
      case LogAction.carDeleted:
        return Colors.red;
      case LogAction.userCreated:
      case LogAction.userLoggedIn:
        return Colors.green;
      case LogAction.userUpdated:
        return Colors.orange;
      case LogAction.userDeleted:
      case LogAction.userLoggedOut:
        return Colors.red;
      case LogAction.favoriteAdded:
        return Colors.pink;
      case LogAction.favoriteRemoved:
        return Colors.grey;
      case LogAction.workerCreated:
      case LogAction.workerUpdated:
        return Colors.purple;
      case LogAction.workerDeleted:
        return Colors.red;
      case LogAction.adminAction:
        return Colors.indigo;
      case LogAction.systemError:
        return Colors.red;
      case LogAction.systemInfo:
        return Colors.blue;
    }
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

  IconData _getResourceIcon(String resourceType) {
    switch (resourceType) {
      case 'car':
        return Icons.directions_car;
      case 'user':
        return Icons.person;
      case 'worker':
        return Icons.work;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.description;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
