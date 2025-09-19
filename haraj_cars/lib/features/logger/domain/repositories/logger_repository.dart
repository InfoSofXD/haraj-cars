import '../models/log_entry.dart';

abstract class LoggerRepository {
  /// Save a log entry to the storage
  Future<void> saveLogEntry(LogEntry logEntry);

  /// Get log entries with optional filtering
  Future<List<LogEntry>> getLogEntries({
    LogFilter? filter,
    int? limit,
    int? offset,
  });

  /// Get log entries for a specific user
  Future<List<LogEntry>> getUserLogEntries(
    String userId, {
    LogFilter? filter,
    int? limit,
    int? offset,
  });

  /// Get log entries for a specific resource
  Future<List<LogEntry>> getResourceLogEntries(
    String resourceId,
    String resourceType, {
    LogFilter? filter,
    int? limit,
    int? offset,
  });

  /// Get log statistics
  Future<LogStatistics> getLogStatistics({
    LogFilter? filter,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Clear old log entries (for maintenance)
  Future<void> clearOldLogs(DateTime beforeDate);

  /// Get log entries count
  Future<int> getLogEntriesCount({LogFilter? filter});
}

class LogStatistics {
  final int totalLogs;
  final int infoCount;
  final int warningCount;
  final int errorCount;
  final int debugCount;
  final Map<String, int> actionCounts;
  final Map<String, int> userCounts;
  final Map<String, int> resourceTypeCounts;
  final DateTime? firstLogDate;
  final DateTime? lastLogDate;

  const LogStatistics({
    required this.totalLogs,
    required this.infoCount,
    required this.warningCount,
    required this.errorCount,
    required this.debugCount,
    required this.actionCounts,
    required this.userCounts,
    required this.resourceTypeCounts,
    this.firstLogDate,
    this.lastLogDate,
  });

  factory LogStatistics.fromJson(Map<String, dynamic> json) {
    return LogStatistics(
      totalLogs: json['total_logs'] as int,
      infoCount: json['info_count'] as int,
      warningCount: json['warning_count'] as int,
      errorCount: json['error_count'] as int,
      debugCount: json['debug_count'] as int,
      actionCounts: Map<String, int>.from(json['action_counts'] as Map),
      userCounts: Map<String, int>.from(json['user_counts'] as Map),
      resourceTypeCounts: Map<String, int>.from(json['resource_type_counts'] as Map),
      firstLogDate: json['first_log_date'] != null 
          ? DateTime.parse(json['first_log_date'] as String)
          : null,
      lastLogDate: json['last_log_date'] != null 
          ? DateTime.parse(json['last_log_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_logs': totalLogs,
      'info_count': infoCount,
      'warning_count': warningCount,
      'error_count': errorCount,
      'debug_count': debugCount,
      'action_counts': actionCounts,
      'user_counts': userCounts,
      'resource_type_counts': resourceTypeCounts,
      'first_log_date': firstLogDate?.toIso8601String(),
      'last_log_date': lastLogDate?.toIso8601String(),
    };
  }
}
