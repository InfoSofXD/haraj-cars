enum LogLevel {
  info('INFO', 'Information'),
  warning('WARNING', 'Warning'),
  error('ERROR', 'Error'),
  debug('DEBUG', 'Debug');

  const LogLevel(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum LogAction {
  // Car actions
  carCreated('car_created', 'Car Created', '🚗'),
  carUpdated('car_updated', 'Car Updated', '✏️'),
  carDeleted('car_deleted', 'Car Deleted', '🗑️'),
  carViewed('car_viewed', 'Car Viewed', '👁️'),
  
  // User actions
  userCreated('user_created', 'User Created', '👤'),
  userUpdated('user_updated', 'User Updated', '✏️'),
  userDeleted('user_deleted', 'User Deleted', '🗑️'),
  userLoggedIn('user_logged_in', 'User Logged In', '🔐'),
  userLoggedOut('user_logged_out', 'User Logged Out', '🚪'),
  
  // Favorites actions
  favoriteAdded('favorite_added', 'Added to Favorites', '❤️'),
  favoriteRemoved('favorite_removed', 'Removed from Favorites', '💔'),
  
  // Worker actions
  workerCreated('worker_created', 'Worker Created', '👷'),
  workerUpdated('worker_updated', 'Worker Updated', '✏️'),
  workerDeleted('worker_deleted', 'Worker Deleted', '🗑️'),
  
  // Admin actions
  adminAction('admin_action', 'Admin Action', '⚙️'),
  
  // System actions
  systemError('system_error', 'System Error', '❌'),
  systemInfo('system_info', 'System Info', 'ℹ️');

  const LogAction(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final String icon;
}

class LogEntry {
  final String id;
  final LogLevel level;
  final LogAction action;
  final String message;
  final String? userId;
  final String? userName;
  final String? userRole;
  final String? resourceId;
  final String? resourceType;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  const LogEntry({
    required this.id,
    required this.level,
    required this.action,
    required this.message,
    this.userId,
    this.userName,
    this.userRole,
    this.resourceId,
    this.resourceType,
    this.metadata,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      level: LogLevel.values.firstWhere(
        (level) => level.value == json['level'],
        orElse: () => LogLevel.info,
      ),
      action: LogAction.values.firstWhere(
        (action) => action.value == json['action'],
        orElse: () => LogAction.systemInfo,
      ),
      message: json['message'] as String,
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String?,
      userRole: json['user_role'] as String?,
      resourceId: json['resource_id'] as String?,
      resourceType: json['resource_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level.value,
      'action': action.value,
      'message': message,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'resource_id': resourceId,
      'resource_type': resourceType,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'ip_address': ipAddress,
      'user_agent': userAgent,
    };
  }

  LogEntry copyWith({
    String? id,
    LogLevel? level,
    LogAction? action,
    String? message,
    String? userId,
    String? userName,
    String? userRole,
    String? resourceId,
    String? resourceType,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
  }) {
    return LogEntry(
      id: id ?? this.id,
      level: level ?? this.level,
      action: action ?? this.action,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      resourceId: resourceId ?? this.resourceId,
      resourceType: resourceType ?? this.resourceType,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  @override
  String toString() {
    return 'LogEntry(id: $id, action: ${action.displayName}, message: $message, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class LogFilter {
  final LogLevel? level;
  final LogAction? action;
  final String? userId;
  final String? userRole;
  final String? resourceType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const LogFilter({
    this.level,
    this.action,
    this.userId,
    this.userRole,
    this.resourceType,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  LogFilter copyWith({
    LogLevel? level,
    LogAction? action,
    String? userId,
    String? userRole,
    String? resourceType,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return LogFilter(
      level: level ?? this.level,
      action: action ?? this.action,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      resourceType: resourceType ?? this.resourceType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
