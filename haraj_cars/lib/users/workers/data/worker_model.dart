
class Worker {
  final int id;
  final DateTime createdAt;
  final String workerName;
  final String workerPhone;
  final String? workerEmail;
  final DateTime? lastLogin;
  final String? workerUuid;
  final String? workerPassword;

  const Worker({
    required this.id,
    required this.createdAt,
    required this.workerName,
    required this.workerPhone,
    this.workerEmail,
    this.lastLogin,
    this.workerUuid,
    this.workerPassword,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      workerName: json['worker_name'] as String? ?? '',
      workerPhone: json['worker_phone'] as String,
      workerEmail: json['worker_email'] as String?,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String)
          : null,
      workerUuid: json['worker_uuid'] as String?,
      workerPassword: json['worker_password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'worker_name': workerName,
      'worker_phone': workerPhone,
      'worker_email': workerEmail,
      'last_login': lastLogin?.toIso8601String(),
      'worker_uuid': workerUuid,
      'worker_password': workerPassword,
    };
  }

  // For creating new workers (without id and timestamps)
  Map<String, dynamic> toCreateJson() {
    return {
      'worker_name': workerName,
      'worker_phone': workerPhone,
      'worker_email': workerEmail,
      'worker_password': workerPassword,
    };
  }

  // For updating workers (without id and created_at)
  Map<String, dynamic> toUpdateJson() {
    return {
      'worker_name': workerName,
      'worker_phone': workerPhone,
      'worker_email': workerEmail,
      'last_login': lastLogin?.toIso8601String(),
      'worker_uuid': workerUuid,
      'worker_password': workerPassword,
    };
  }

  Worker copyWith({
    int? id,
    DateTime? createdAt,
    String? workerName,
    String? workerPhone,
    String? workerEmail,
    DateTime? lastLogin,
    String? workerUuid,
    String? workerPassword,
  }) {
    return Worker(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      workerName: workerName ?? this.workerName,
      workerPhone: workerPhone ?? this.workerPhone,
      workerEmail: workerEmail ?? this.workerEmail,
      lastLogin: lastLogin ?? this.lastLogin,
      workerUuid: workerUuid ?? this.workerUuid,
      workerPassword: workerPassword ?? this.workerPassword,
    );
  }

  @override
  String toString() {
    return 'Worker(id: $id, name: $workerName, phone: $workerPhone)';
  }
}

class WorkerAction {
  final String id;
  final String workerId;
  final String action;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const WorkerAction({
    required this.id,
    required this.workerId,
    required this.action,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory WorkerAction.fromJson(Map<String, dynamic> json) {
    return WorkerAction(
      id: json['id'] as String,
      workerId: json['worker_id'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worker_id': workerId,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'WorkerAction(id: $id, action: $action, timestamp: $timestamp)';
  }
}
