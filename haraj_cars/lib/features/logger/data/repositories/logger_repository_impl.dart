import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/models/log_entry.dart';
import '../../domain/repositories/logger_repository.dart';

class LoggerRepositoryImpl implements LoggerRepository {
  static const String _logsKey = 'app_logs';
  static const int _maxLogsInMemory = 1000; // Keep only last 1000 logs in memory

  @override
  Future<void> saveLogEntry(LogEntry logEntry) async {
    try {
      final existingLogs = await _getStoredLogs();
      
      // Add new log entry
      existingLogs.add(logEntry);
      
      // Keep only the most recent logs to prevent memory issues
      if (existingLogs.length > _maxLogsInMemory) {
        existingLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        existingLogs.removeRange(_maxLogsInMemory, existingLogs.length);
      }
      
      // Save back to storage
      await _saveLogs(existingLogs);
      
      print('📝 LOG: ${logEntry.action.displayName} - ${logEntry.message}');
    } catch (e) {
      print('❌ Failed to save log entry: $e');
    }
  }

  @override
  Future<List<LogEntry>> getLogEntries({
    LogFilter? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      List<LogEntry> logs = await _getStoredLogs();
      
      // Apply filters
      if (filter != null) {
        logs = _applyFilter(logs, filter);
      }
      
      // Sort by timestamp (newest first)
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply pagination
      if (offset != null && offset > 0) {
        logs = logs.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        logs = logs.take(limit).toList();
      }
      
      return logs;
    } catch (e) {
      print('❌ Failed to get log entries: $e');
      return [];
    }
  }

  @override
  Future<List<LogEntry>> getUserLogEntries(
    String userId, {
    LogFilter? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      List<LogEntry> logs = await _getStoredLogs();
      
      // Filter by user ID
      logs = logs.where((log) => log.userId == userId).toList();
      
      // Apply additional filters
      if (filter != null) {
        logs = _applyFilter(logs, filter);
      }
      
      // Sort by timestamp (newest first)
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply pagination
      if (offset != null && offset > 0) {
        logs = logs.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        logs = logs.take(limit).toList();
      }
      
      return logs;
    } catch (e) {
      print('❌ Failed to get user log entries: $e');
      return [];
    }
  }

  @override
  Future<List<LogEntry>> getResourceLogEntries(
    String resourceId,
    String resourceType, {
    LogFilter? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      List<LogEntry> logs = await _getStoredLogs();
      
      // Filter by resource
      logs = logs.where((log) => 
          log.resourceId == resourceId && log.resourceType == resourceType).toList();
      
      // Apply additional filters
      if (filter != null) {
        logs = _applyFilter(logs, filter);
      }
      
      // Sort by timestamp (newest first)
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply pagination
      if (offset != null && offset > 0) {
        logs = logs.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        logs = logs.take(limit).toList();
      }
      
      return logs;
    } catch (e) {
      print('❌ Failed to get resource log entries: $e');
      return [];
    }
  }

  @override
  Future<LogStatistics> getLogStatistics({
    LogFilter? filter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<LogEntry> logs = await _getStoredLogs();
      
      // Apply date filter
      if (startDate != null) {
        logs = logs.where((log) => log.timestamp.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        logs = logs.where((log) => log.timestamp.isBefore(endDate)).toList();
      }
      
      // Apply additional filters
      if (filter != null) {
        logs = _applyFilter(logs, filter);
      }
      
      // Calculate statistics
      int infoCount = logs.where((log) => log.level == LogLevel.info).length;
      int warningCount = logs.where((log) => log.level == LogLevel.warning).length;
      int errorCount = logs.where((log) => log.level == LogLevel.error).length;
      int debugCount = logs.where((log) => log.level == LogLevel.debug).length;
      
      Map<String, int> actionCounts = {};
      Map<String, int> userCounts = {};
      Map<String, int> resourceTypeCounts = {};
      
      DateTime? firstLogDate;
      DateTime? lastLogDate;
      
      for (final log in logs) {
        // Action counts
        actionCounts[log.action.value] = (actionCounts[log.action.value] ?? 0) + 1;
        
        // User counts
        if (log.userId != null) {
          userCounts[log.userId!] = (userCounts[log.userId!] ?? 0) + 1;
        }
        
        // Resource type counts
        if (log.resourceType != null) {
          resourceTypeCounts[log.resourceType!] = (resourceTypeCounts[log.resourceType!] ?? 0) + 1;
        }
        
        // Date range
        if (firstLogDate == null || log.timestamp.isBefore(firstLogDate)) {
          firstLogDate = log.timestamp;
        }
        if (lastLogDate == null || log.timestamp.isAfter(lastLogDate)) {
          lastLogDate = log.timestamp;
        }
      }
      
      return LogStatistics(
        totalLogs: logs.length,
        infoCount: infoCount,
        warningCount: warningCount,
        errorCount: errorCount,
        debugCount: debugCount,
        actionCounts: actionCounts,
        userCounts: userCounts,
        resourceTypeCounts: resourceTypeCounts,
        firstLogDate: firstLogDate,
        lastLogDate: lastLogDate,
      );
    } catch (e) {
      print('❌ Failed to get log statistics: $e');
      return const LogStatistics(
        totalLogs: 0,
        infoCount: 0,
        warningCount: 0,
        errorCount: 0,
        debugCount: 0,
        actionCounts: {},
        userCounts: {},
        resourceTypeCounts: {},
      );
    }
  }

  @override
  Future<void> clearOldLogs(DateTime beforeDate) async {
    try {
      final existingLogs = await _getStoredLogs();
      
      // Remove logs older than the specified date
      final filteredLogs = existingLogs.where((log) => log.timestamp.isAfter(beforeDate)).toList();
      
      await _saveLogs(filteredLogs);
      
      print('🧹 Cleared ${existingLogs.length - filteredLogs.length} old log entries');
    } catch (e) {
      print('❌ Failed to clear old logs: $e');
    }
  }

  @override
  Future<int> getLogEntriesCount({LogFilter? filter}) async {
    try {
      List<LogEntry> logs = await _getStoredLogs();
      
      if (filter != null) {
        logs = _applyFilter(logs, filter);
      }
      
      return logs.length;
    } catch (e) {
      print('❌ Failed to get log entries count: $e');
      return 0;
    }
  }

  // Private helper methods
  Future<List<LogEntry>> _getStoredLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList(_logsKey) ?? [];
      
      return logsJson.map((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return LogEntry.fromJson(json);
      }).toList();
    } catch (e) {
      print('❌ Failed to get stored logs: $e');
      return [];
    }
  }

  Future<void> _saveLogs(List<LogEntry> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = logs.map((log) => jsonEncode(log.toJson())).toList();
      await prefs.setStringList(_logsKey, logsJson);
    } catch (e) {
      print('❌ Failed to save logs: $e');
    }
  }

  List<LogEntry> _applyFilter(List<LogEntry> logs, LogFilter filter) {
    return logs.where((log) {
      // Level filter
      if (filter.level != null && log.level != filter.level) {
        return false;
      }
      
      // Action filter
      if (filter.action != null && log.action != filter.action) {
        return false;
      }
      
      // User ID filter
      if (filter.userId != null && log.userId != filter.userId) {
        return false;
      }
      
      // User role filter
      if (filter.userRole != null && log.userRole != filter.userRole) {
        return false;
      }
      
      // Resource type filter
      if (filter.resourceType != null && log.resourceType != filter.resourceType) {
        return false;
      }
      
      // Date range filter
      if (filter.startDate != null && log.timestamp.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null && log.timestamp.isAfter(filter.endDate!)) {
        return false;
      }
      
      // Search query filter
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        if (!log.message.toLowerCase().contains(query) &&
            !log.action.displayName.toLowerCase().contains(query) &&
            (log.userName?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
}
