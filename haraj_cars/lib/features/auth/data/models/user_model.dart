import 'package:haraj/core/constants/user_roles.dart';

import '../../domain/entities/user_entity.dart';

/// User data model for API communication
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.username,
    super.fullName,
    super.phoneNumber,
    required super.role,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.isActive = true,
    super.metadata,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      role: UserRole.fromString(json['role'] ?? 'client'),
      profileImageUrl: json['profile_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
      metadata: json['metadata'],
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role.value,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'metadata': metadata,
    };
  }

  /// Create UserModel from Supabase User
  factory UserModel.fromSupabaseUser(dynamic supabaseUser, {UserRole? role}) {
    return UserModel(
      id: supabaseUser.id ?? '',
      email: supabaseUser.email ?? '',
      username: supabaseUser.userMetadata?['username'],
      fullName: supabaseUser.userMetadata?['full_name'],
      phoneNumber: supabaseUser.userMetadata?['phone_number'],
      role: role ?? UserRole.client,
      profileImageUrl: supabaseUser.userMetadata?['profile_image_url'],
      createdAt: supabaseUser.createdAt != null 
          ? DateTime.parse(supabaseUser.createdAt) 
          : DateTime.now(),
      updatedAt: supabaseUser.updatedAt != null 
          ? DateTime.parse(supabaseUser.updatedAt) 
          : DateTime.now(),
      isActive: true,
      metadata: supabaseUser.userMetadata,
    );
  }

  /// Convert to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: role,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      metadata: metadata,
    );
  }

  /// Copy with method
  @override
  UserModel copyWith({
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
    return UserModel(
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
}
