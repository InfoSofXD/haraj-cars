import 'worker_service.dart';
import 'worker_model.dart';

class WorkerAuthResult {
  final bool isSuccess;
  final Worker? worker;
  final String? error;

  WorkerAuthResult._({
    required this.isSuccess,
    this.worker,
    this.error,
  });

  factory WorkerAuthResult.success(Worker worker) {
    return WorkerAuthResult._(isSuccess: true, worker: worker);
  }

  factory WorkerAuthResult.failure(String error) {
    return WorkerAuthResult._(isSuccess: false, error: error);
  }
}

class WorkerAuthService {
  static final WorkerAuthService _instance = WorkerAuthService._internal();
  factory WorkerAuthService() => _instance;
  WorkerAuthService._internal();

  final WorkerService _workerService = WorkerService();
  Worker? _currentWorker;

  /// Get current authenticated worker
  Worker? get currentWorker => _currentWorker;

  /// Check if worker is authenticated
  bool get isAuthenticated => _currentWorker != null;

  /// Sign in worker with phone and password
  Future<WorkerAuthResult> signIn({
    required String phone,
    required String password,
  }) async {
    try {
      if (phone.isEmpty || password.isEmpty) {
        return WorkerAuthResult.failure('Phone and password are required');
      }

      final worker = await _workerService.authenticateWorker(phone, password);
      
      if (worker != null) {
        _currentWorker = worker;
        return WorkerAuthResult.success(worker);
      } else {
        return WorkerAuthResult.failure('Invalid phone number or password');
      }
    } catch (e) {
      return WorkerAuthResult.failure('Authentication failed: $e');
    }
  }

  /// Sign in worker with name and password
  Future<WorkerAuthResult> signInWithName({
    required String name,
    required String password,
  }) async {
    try {
      if (name.isEmpty || password.isEmpty) {
        return WorkerAuthResult.failure('Name and password are required');
      }

      final worker = await _workerService.authenticateWorkerByName(name, password);
      
      if (worker != null) {
        _currentWorker = worker;
        return WorkerAuthResult.success(worker);
      } else {
        return WorkerAuthResult.failure('Invalid name or password');
      }
    } catch (e) {
      return WorkerAuthResult.failure('Authentication failed: $e');
    }
  }

  /// Sign in worker with either phone or name and password
  Future<WorkerAuthResult> signInFlexible({
    required String identifier, // Can be phone or name
    required String password,
  }) async {
    try {
      if (identifier.isEmpty || password.isEmpty) {
        return WorkerAuthResult.failure('Identifier and password are required');
      }

      // Try phone first (if it looks like a phone number)
      if (identifier.startsWith('+') || RegExp(r'^\d+$').hasMatch(identifier)) {
        final worker = await _workerService.authenticateWorker(identifier, password);
        if (worker != null) {
          _currentWorker = worker;
          return WorkerAuthResult.success(worker);
        }
      }

      // Try name
      final worker = await _workerService.authenticateWorkerByName(identifier, password);
      if (worker != null) {
        _currentWorker = worker;
        return WorkerAuthResult.success(worker);
      }

      return WorkerAuthResult.failure('Invalid identifier or password');
    } catch (e) {
      return WorkerAuthResult.failure('Authentication failed: $e');
    }
  }

  /// Sign out current worker
  Future<void> signOut() async {
    _currentWorker = null;
  }

  /// Create a new worker account
  Future<WorkerAuthResult> createWorker({
    required String workerName,
    required String workerPhone,
    String? workerEmail,
    String? workerPassword,
  }) async {
    try {
      if (workerName.isEmpty || workerPhone.isEmpty) {
        return WorkerAuthResult.failure('Name and phone are required');
      }

      // Check if worker with this phone already exists
      final existingWorker = await _workerService.getWorkerByPhone(workerPhone);
      if (existingWorker != null) {
        return WorkerAuthResult.failure('Worker with this phone number already exists');
      }

      final worker = await _workerService.createWorker(
        workerName: workerName,
        workerPhone: workerPhone,
        workerEmail: workerEmail,
        workerPassword: workerPassword,
      );

      if (worker != null) {
        return WorkerAuthResult.success(worker);
      } else {
        return WorkerAuthResult.failure('Failed to create worker account');
      }
    } catch (e) {
      return WorkerAuthResult.failure('Failed to create worker: $e');
    }
  }

  /// Update worker password
  Future<bool> updatePassword(String newPassword) async {
    if (_currentWorker == null) return false;

    try {
      final updatedWorker = _currentWorker!.copyWith(
        workerPassword: newPassword,
      );

      final result = await _workerService.updateWorker(updatedWorker);
      if (result != null) {
        _currentWorker = result;
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  /// Update worker profile
  Future<bool> updateProfile({
    String? workerName,
    String? workerPhone,
    String? workerEmail,
  }) async {
    if (_currentWorker == null) return false;

    try {
      final updatedWorker = _currentWorker!.copyWith(
        workerName: workerName,
        workerPhone: workerPhone,
        workerEmail: workerEmail,
      );

      final result = await _workerService.updateWorker(updatedWorker);
      if (result != null) {
        _currentWorker = result;
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}
