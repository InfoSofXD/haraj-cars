import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_role.dart';

class AppUser {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.phone,
    required this.role,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
    this.avatarUrl,
  });

  UserPermissions get permissions => UserPermissions.forRole(role);

  bool get isSuperAdmin => role.isSuperAdmin;
  bool get isWorker => role.isWorker;
  bool get isClient => role.isClient;
  bool get isAdmin => role.isAdmin;

  factory AppUser.fromSupabaseUser(User user, {UserRole? role}) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['username'] as String?,
      fullName: user.userMetadata?['full_name'] as String?,
      phone: user.userMetadata?['phone'] as String?,
      role: role ?? UserRole.client,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      isActive: true,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'client'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'phone': phone,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
      'avatar_url': avatarUrl,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, role: ${role.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
