import 'package:haraj/core/constants/user_roles.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
    String? username,
    String? phoneNumber,
    UserRole role = UserRole.client,
  }) async {
    // Validate input
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }

    if (fullName.isEmpty) {
      return const Left(ValidationFailure('Full name cannot be empty'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Please enter a valid email address'));
    }

    if (password.length < 6) {
      return const Left(ValidationFailure('Password must be at least 6 characters'));
    }

    if (fullName.length < 2) {
      return const Left(ValidationFailure('Full name must be at least 2 characters'));
    }

    // Validate phone number if provided
    if (phoneNumber != null && phoneNumber.isNotEmpty && !_isValidPhoneNumber(phoneNumber)) {
      return const Left(ValidationFailure('Please enter a valid phone number'));
    }

    return await repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
      username: username,
      phoneNumber: phoneNumber,
      role: role,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Basic phone number validation - can be enhanced based on requirements
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phoneNumber);
  }
}
