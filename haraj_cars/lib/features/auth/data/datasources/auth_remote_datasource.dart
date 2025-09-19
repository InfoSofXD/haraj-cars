import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? username,
    String? phoneNumber,
    UserRole role = UserRole.client,
  });

  Future<UserModel> signInAsAdmin({
    required String username,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<bool> isSignedIn();

  Future<UserModel> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    String? profileImageUrl,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> resetPassword({
    required String email,
  });

  Future<void> verifyEmail();

  Future<void> deleteAccount();

  Stream<UserModel?> get authStateChanges;
}

/// Implementation of AuthRemoteDataSource using Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign in failed');
      }

      // Get user role from database
      final userRole = await _getUserRole(response.user!.id);
      
      return UserModel.fromSupabaseUser(response.user!, role: userRole);
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? username,
    String? phoneNumber,
    UserRole role = UserRole.client,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username,
          'phone_number': phoneNumber,
          'role': role.value,
        },
      );

      if (response.user == null) {
        throw const AuthException('Sign up failed');
      }

      return UserModel.fromSupabaseUser(response.user!, role: role);
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInAsAdmin({
    required String username,
    required String password,
  }) async {
    try {
      // Check admin credentials in admin table
      final response = await supabaseClient
          .from(AppConstants.adminTable)
          .select()
          .eq('username', username)
          .eq('password', password);

      if (response.isEmpty) {
        throw const AuthException('Invalid admin credentials');
      }

      final adminData = response.first;
      
      // Create a mock user for admin (since they don't go through Supabase auth)
      return UserModel(
        id: adminData['id']?.toString() ?? '',
        email: adminData['email'] ?? '',
        username: adminData['username'],
        fullName: adminData['full_name'],
        phoneNumber: adminData['phone_number'],
        role: UserRole.superAdmin,
        profileImageUrl: adminData['profile_image_url'],
        createdAt: DateTime.parse(adminData['created_at']),
        updatedAt: DateTime.parse(adminData['updated_at']),
        isActive: adminData['is_active'] ?? true,
        metadata: adminData,
      );
    } catch (e) {
      throw AuthException('Admin sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final userRole = await _getUserRole(user.id);
      return UserModel.fromSupabaseUser(user, role: userRole);
    } catch (e) {
      throw AuthException('Get current user failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final user = supabaseClient.auth.currentUser;
      return user != null;
    } catch (e) {
      throw AuthException('Check sign in status failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (username != null) updateData['username'] = username;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;

      await supabaseClient.auth.updateUser(
        supabase.UserAttributes(data: updateData),
      );

      final updatedUser = supabaseClient.auth.currentUser!;
      final userRole = await _getUserRole(updatedUser.id);
      
      return UserModel.fromSupabaseUser(updatedUser, role: userRole);
    } catch (e) {
      throw AuthException('Update profile failed: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await supabaseClient.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException('Change password failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Reset password failed: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyEmail() async {
    try {
      await supabaseClient.auth.resend(type: supabase.OtpType.signup);
    } catch (e) {
      throw AuthException('Verify email failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      await supabaseClient.auth.admin.deleteUser(user.id);
    } catch (e) {
      throw AuthException('Delete account failed: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      if (user == null) return null;

      // Get user role asynchronously
      return _getUserRole(user.id).then((role) {
        return UserModel.fromSupabaseUser(user, role: role);
      });
    }).asyncMap((future) => future);
  }

  /// Get user role from database
  Future<UserRole> _getUserRole(String userId) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.usersTable)
          .select('role')
          .eq('id', userId)
          .single();

      return UserRole.fromString(response['role'] ?? 'client');
    } catch (e) {
      // Default to client role if not found
      return UserRole.client;
    }
  }
}
