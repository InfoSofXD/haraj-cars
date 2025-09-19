import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;
  bool get isWorker => _currentUser?.isWorker ?? false;
  bool get isClient => _currentUser?.isClient ?? false;

  UserPermissions? get permissions => _currentUser?.permissions;

  Future<AuthResult<AppUser>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? username,
    UserRole role = UserRole.client,
  }) async {
    try {
      print('🔍 DEBUG: SignUp - Email: $email, Role: ${role.displayName}');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'username': username,
          'role': role.value,
        },
      );

      print('🔍 DEBUG: SignUp response: ${response.user != null ? 'SUCCESS' : 'FAILED'}');
      if (response.user != null) {
        print('🔍 DEBUG: User ID: ${response.user!.id}');
      }

      if (response.user != null) {
        final appUser = AppUser.fromSupabaseUser(response.user!, role: role);
        
        // Store user in our custom users table
        print('🔍 DEBUG: Storing user in database...');
        await _storeUserInDatabase(appUser);
        print('🔍 DEBUG: User stored successfully');
        
        _currentUser = appUser;
        return AuthResult.success(appUser);
      } else {
        return AuthResult.failure('Failed to create account');
      }
    } on AuthException catch (e) {
      print('🔍 DEBUG: SignUp AuthException: ${e.message}');
      return AuthResult.failure(_getErrorMessage(e.message));
    } catch (e) {
      print('🔍 DEBUG: SignUp General Exception: $e');
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  Future<AuthResult<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user role from our custom users table
        final userRole = await _getUserRole(response.user!.id);
        final appUser = AppUser.fromSupabaseUser(response.user!, role: userRole);
        
        _currentUser = appUser;
        return AuthResult.success(appUser);
      } else {
        return AuthResult.failure('Failed to sign in');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.message));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  Future<AuthResult<AppUser>> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      print('🔍 DEBUG: Attempting to sign in with username: $username');
      print('🔍 DEBUG: Password length: ${password.length} characters');

      // Check if it's the default admin - bypass Supabase auth
      if (username == 'admin' && password == '1234') {
        print('🔍 DEBUG: Admin credentials detected - bypassing Supabase auth');
        
        // Create a local admin user object
        final adminUser = AppUser(
          id: 'admin-local-id',
          email: 'admin@harajcars.com',
          username: 'admin',
          fullName: 'Default Admin',
          phone: '+1234567890',
          role: UserRole.superAdmin,
          createdAt: DateTime.now(),
          isActive: true,
        );
        
        _currentUser = adminUser;
        print('🔍 DEBUG: Admin login successful - role: ${adminUser.role.displayName}');
        return AuthResult.success(adminUser);
      }

      // For other users, use Supabase authentication
      String email;
      if (username == 'admin') {
        email = 'admin@harajcars.com';
      } else {
        email = '$username@harajcars.com';
      }

      print('🔍 DEBUG: Using Supabase auth for email: $email');

      // Try to sign in with the email
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('🔍 DEBUG: Supabase sign in response: ${response.user != null ? 'SUCCESS' : 'FAILED'}');

      if (response.user != null) {
        // Get user role from our custom users table
        final userRole = await _getUserRole(response.user!.id);
        final appUser = AppUser.fromSupabaseUser(response.user!, role: userRole);
        
        print('🔍 DEBUG: User role: ${userRole.displayName}');
        
        _currentUser = appUser;
        return AuthResult.success(appUser);
      } else {
        return AuthResult.failure('Failed to sign in');
      }
    } on AuthException catch (e) {
      print('🔍 DEBUG: AuthException: ${e.message}');
      return AuthResult.failure(_getErrorMessage(e.message));
    } catch (e) {
      print('🔍 DEBUG: General Exception: $e');
      return AuthResult.failure('Invalid username or password');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  Future<void> initializeAuth() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final userRole = await _getUserRole(user.id);
      _currentUser = AppUser.fromSupabaseUser(user, role: userRole);
    }
  }

  Future<UserRole> _getUserRole(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();
      
      return UserRole.fromString(response['role'] as String? ?? 'client');
    } catch (e) {
      // If user doesn't exist in our table, default to client
      return UserRole.client;
    }
  }

  Future<void> _storeUserInDatabase(AppUser user) async {
    try {
      await _supabase.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'username': user.username,
        'full_name': user.fullName,
        'phone': user.phone,
        'role': user.role.value,
        'is_active': user.isActive,
        'created_at': user.createdAt.toIso8601String(),
        'updated_at': user.updatedAt?.toIso8601String(),
      });
    } catch (e) {
      print('Error storing user in database: $e');
    }
  }

  Future<AuthResult<AppUser>> updateUserRole(String userId, UserRole newRole) async {
    if (!isSuperAdmin) {
      return AuthResult.failure('Only super admins can update user roles');
    }

    try {
      await _supabase
          .from('users')
          .update({'role': newRole.value})
          .eq('id', userId);

      // If updating current user, refresh current user data
      if (_currentUser?.id == userId) {
        _currentUser = _currentUser!.copyWith(role: newRole);
      }

      return AuthResult.success(_currentUser!);
    } catch (e) {
      return AuthResult.failure('Failed to update user role: $e');
    }
  }

  Future<List<AppUser>> getAllUsers() async {
    if (!isSuperAdmin) {
      throw Exception('Only super admins can view all users');
    }

    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AppUser.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<bool> deleteUser(String userId) async {
    if (!isSuperAdmin) {
      throw Exception('Only super admins can delete users');
    }

    try {
      // Delete from our users table
      await _supabase.from('users').delete().eq('id', userId);
      
      // Delete from auth.users (requires special permissions)
      await _supabase.rpc('delete_user_account', params: {'user_id': userId});
      
      return true;
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<AuthResult<AppUser>> createDefaultAdmin() async {
    try {
      print('🔍 DEBUG: Default admin is ready!');
      
      // Since we're bypassing Supabase auth for admin, just return success
      // The admin credentials are hardcoded: username: admin, password: 1234
      
      final adminUser = AppUser(
        id: 'admin-local-id',
        email: 'admin@harajcars.com',
        username: 'admin',
        fullName: 'Default Admin',
        phone: '+1234567890',
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      print('🔍 DEBUG: Default admin credentials ready');
      print('🔍 DEBUG: Username: admin, Password: 1234');
      
      return AuthResult.success(adminUser);
    } catch (e) {
      print('🔍 DEBUG: Exception in createDefaultAdmin: $e');
      return AuthResult.failure('Failed to create default admin: $e');
    }
  }

  String _getErrorMessage(String message) {
    switch (message) {
      case 'Invalid login credentials':
        return 'Invalid email or password.';
      case 'Email not confirmed':
        return 'Please check your email and confirm your account.';
      case 'Invalid email':
        return 'Please enter a valid email address.';
      case 'User already registered':
        return 'An account with this email already exists.';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';
      default:
        return message;
    }
  }
}

class AuthResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  AuthResult._(this.isSuccess, this.data, this.error);

  factory AuthResult.success(T data) => AuthResult._(true, data, null);
  factory AuthResult.failure(String error) => AuthResult._(false, null, error);
}
