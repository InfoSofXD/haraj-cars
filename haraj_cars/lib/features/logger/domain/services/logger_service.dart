import '../models/log_entry.dart';
import '../repositories/logger_repository.dart';
import '../../../../core/services/auth_service.dart';

class LoggerService {
  final LoggerRepository _repository;
  final AuthService _authService;

  LoggerService(this._repository, this._authService);

  /// Log a car-related action
  Future<void> logCarAction({
    required LogAction action,
    required String message,
    String? carId,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.info,
      action: action,
      message: message,
      resourceId: carId,
      resourceType: 'car',
      metadata: metadata,
    );
  }

  /// Log a user-related action
  Future<void> logUserAction({
    required LogAction action,
    required String message,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.info,
      action: action,
      message: message,
      resourceId: userId,
      resourceType: 'user',
      metadata: metadata,
    );
  }

  /// Log a worker-related action
  Future<void> logWorkerAction({
    required LogAction action,
    required String message,
    String? workerId,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.info,
      action: action,
      message: message,
      resourceId: workerId,
      resourceType: 'worker',
      metadata: metadata,
    );
  }

  /// Log a favorite action
  Future<void> logFavoriteAction({
    required LogAction action,
    required String message,
    String? carId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.info,
      action: action,
      message: message,
      resourceId: carId,
      resourceType: 'favorite',
      metadata: {
        ...?metadata,
        'car_id': carId,
        'user_id': userId,
      },
    );
  }

  /// Log an admin action
  Future<void> logAdminAction({
    required String message,
    String? resourceId,
    String? resourceType,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.info,
      action: LogAction.adminAction,
      message: message,
      resourceId: resourceId,
      resourceType: resourceType,
      metadata: metadata,
    );
  }

  /// Log a system error
  Future<void> logError({
    required String message,
    String? resourceId,
    String? resourceType,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.error,
      action: LogAction.systemError,
      message: message,
      resourceId: resourceId,
      resourceType: resourceType,
      metadata: metadata,
    );
  }

  /// Log a system warning
  Future<void> logWarning({
    required String message,
    String? resourceId,
    String? resourceType,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.warning,
      action: LogAction.systemInfo,
      message: message,
      resourceId: resourceId,
      resourceType: resourceType,
      metadata: metadata,
    );
  }

  /// Log a system info message
  Future<void> logInfo({
    required String message,
    String? resourceId,
    String? resourceType,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.info,
      action: LogAction.systemInfo,
      message: message,
      resourceId: resourceId,
      resourceType: resourceType,
      metadata: metadata,
    );
  }

  /// Log a debug message
  Future<void> logDebug({
    required String message,
    String? resourceId,
    String? resourceType,
    Map<String, dynamic>? metadata,
  }) async {
    await _logAction(
      level: LogLevel.debug,
      action: LogAction.systemInfo,
      message: message,
      resourceId: resourceId,
      resourceType: resourceType,
      metadata: metadata,
    );
  }

  /// Get log entries with filtering
  Future<List<LogEntry>> getLogEntries({
    LogFilter? filter,
    int? limit,
    int? offset,
  }) async {
    return await _repository.getLogEntries(
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }

  /// Get user-specific log entries
  Future<List<LogEntry>> getUserLogEntries(
    String userId, {
    LogFilter? filter,
    int? limit,
    int? offset,
  }) async {
    return await _repository.getUserLogEntries(
      userId,
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }

  /// Get resource-specific log entries
  Future<List<LogEntry>> getResourceLogEntries(
    String resourceId,
    String resourceType, {
    LogFilter? filter,
    int? limit,
    int? offset,
  }) async {
    return await _repository.getResourceLogEntries(
      resourceId,
      resourceType,
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }

  /// Get log statistics
  Future<LogStatistics> getLogStatistics({
    LogFilter? filter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getLogStatistics(
      filter: filter,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Clear old logs
  Future<void> clearOldLogs(DateTime beforeDate) async {
    await _repository.clearOldLogs(beforeDate);
  }

  /// Get log count
  Future<int> getLogCount({LogFilter? filter}) async {
    return await _repository.getLogEntriesCount(filter: filter);
  }

  // Private method to create and save log entries
  Future<void> _logAction({
    required LogLevel level,
    required LogAction action,
    required String message,
    String? resourceId,
    String? resourceType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      
      final logEntry = LogEntry(
        id: _generateLogId(),
        level: level,
        action: action,
        message: message,
        userId: currentUser?.id,
        userName: currentUser?.fullName ?? currentUser?.email,
        userRole: currentUser?.role.displayName,
        resourceId: resourceId,
        resourceType: resourceType,
        metadata: metadata,
        timestamp: DateTime.now(),
        // Note: In a real app, you'd get these from the request context
        ipAddress: null,
        userAgent: null,
      );

      await _repository.saveLogEntry(logEntry);
    } catch (e) {
      // Don't let logging errors break the app
      print('❌ Failed to log action: $e');
    }
  }

  String _generateLogId() {
    return 'log_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
  }
}
