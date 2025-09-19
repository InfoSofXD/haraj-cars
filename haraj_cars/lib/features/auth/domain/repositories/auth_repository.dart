import 'package:haraj/core/constants/user_roles.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? username,
    String? phoneNumber,
    UserRole role = UserRole.client,
  });

  /// Sign in as admin with username and password
  Future<Either<Failure, UserEntity>> signInAsAdmin({
    required String username,
    required String password,
  });

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Check if user is signed in
  Future<Either<Failure, bool>> isSignedIn();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? username,
    String? phoneNumber,
    String? profileImageUrl,
  });

  /// Change password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Reset password
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Verify email
  Future<Either<Failure, void>> verifyEmail();

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Stream of authentication state changes
  Stream<Either<Failure, UserEntity?>> get authStateChanges;
}
