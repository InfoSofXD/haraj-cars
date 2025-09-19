
import 'package:haraj/core/constants/user_roles.dart';

/// User entity representing a user in the system
class UserEntity {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? phoneNumber;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.metadata,
  });

  /// Check if user is a super admin
  bool get isSuperAdmin => role == UserRole.superAdmin;

  /// Check if user is a worker
  bool get isWorker => role == UserRole.worker;

  /// Check if user is a client
  bool get isClient => role == UserRole.client;

  /// Check if user can manage cars
  bool get canManageCars => role.canManageCars;

  /// Check if user can access admin panel
  bool get canAccessAdminPanel => role.canAccessAdminPanel;

  /// Check if user can manage users
  bool get canManageUsers => role.canManageUsers;

  /// Check if user can view analytics
  bool get canViewAnalytics => role.canViewAnalytics;

  /// Get display name (full name or username or email)
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (username != null && username!.isNotEmpty) return username!;
    return email;
  }

  /// Copy with method for immutable updates
  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, role: $role, displayName: $displayName)';
  }
}
