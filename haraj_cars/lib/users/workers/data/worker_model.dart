
class Worker {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final DateTime joinDate;
  final bool isActive;
  final String? avatarUrl;
  final List<String> permissions;
  final Map<String, dynamic>? metadata;

  const Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.joinDate,
    required this.isActive,
    this.avatarUrl,
    required this.permissions,
    this.metadata,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      position: json['position'] as String,
      joinDate: DateTime.parse(json['join_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String?,
      permissions: List<String>.from(json['permissions'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'join_date': joinDate.toIso8601String(),
      'is_active': isActive,
      'avatar_url': avatarUrl,
      'permissions': permissions,
      'metadata': metadata,
    };
  }

  Worker copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? position,
    DateTime? joinDate,
    bool? isActive,
    String? avatarUrl,
    List<String>? permissions,
    Map<String, dynamic>? metadata,
  }) {
    return Worker(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      permissions: permissions ?? this.permissions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Worker(id: $id, name: $name, position: $position)';
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
