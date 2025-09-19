import 'worker_service.dart';
import 'worker_model.dart';

/// Debug helper to create test workers for development
class WorkerDebugHelper {
  static final WorkerService _workerService = WorkerService();

  /// Create a worker with custom data
  static Future<Worker?> createWorker({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      print('🔧 Creating worker: $name...');
      
      final worker = await _workerService.createWorker(
        workerName: name,
        workerPhone: phone,
        workerEmail: email,
        workerPassword: password,
      );

      if (worker != null) {
        print('✅ Worker created successfully!');
        print('📱 Phone: ${worker.workerPhone}');
        print('🔑 Password: $password');
        print('👤 Name: ${worker.workerName}');
        print('📧 Email: ${worker.workerEmail}');
        return worker;
      } else {
        print('❌ Failed to create worker');
        return null;
      }
    } catch (e) {
      print('❌ Error creating worker: $e');
      return null;
    }
  }

  /// Create multiple workers from a list
  static Future<List<Worker>> createMultipleWorkers(List<Map<String, String>> workersData) async {
    final workers = <Worker>[];

    for (final data in workersData) {
      try {
        final worker = await _workerService.createWorker(
          workerName: data['name']!,
          workerPhone: data['phone']!,
          workerEmail: data['email']!,
          workerPassword: data['password']!,
        );
        
        if (worker != null) {
          workers.add(worker);
          print('✅ Created worker: ${worker.workerName}');
        }
      } catch (e) {
        print('❌ Error creating worker ${data['name']}: $e');
      }
    }

    print('🎉 Created ${workers.length} workers');
    return workers;
  }

  /// List all workers in the database
  static Future<void> listAllWorkers() async {
    try {
      print('📋 Fetching all workers...');
      final workers = await _workerService.getAllWorkers();
      
      if (workers.isEmpty) {
        print('📭 No workers found in database');
        print('💡 Use createTestWorker() to add a test worker');
      } else {
        print('👥 Found ${workers.length} workers:');
        for (final worker in workers) {
          print('  - ${worker.workerName} (${worker.workerPhone})');
        }
      }
    } catch (e) {
      print('❌ Error fetching workers: $e');
    }
  }

  /// Test worker authentication by phone
  static Future<void> testWorkerAuth(String phone, String password) async {
    try {
      print('🔐 Testing worker authentication by phone...');
      print('📱 Phone: $phone');
      print('🔑 Password: $password');
      
      final worker = await _workerService.authenticateWorker(phone, password);
      
      if (worker != null) {
        print('✅ Authentication successful!');
        print('👤 Worker: ${worker.workerName}');
        print('📧 Email: ${worker.workerEmail}');
        print('🆔 ID: ${worker.id}');
      } else {
        print('❌ Authentication failed - worker not found');
        print('💡 Make sure the worker exists and credentials are correct');
      }
    } catch (e) {
      print('❌ Error during authentication: $e');
    }
  }

  /// Test worker authentication by name
  static Future<void> testWorkerAuthByName(String name, String password) async {
    try {
      print('🔐 Testing worker authentication by name...');
      print('👤 Name: $name');
      print('🔑 Password: $password');
      
      final worker = await _workerService.authenticateWorkerByName(name, password);
      
      if (worker != null) {
        print('✅ Authentication successful!');
        print('👤 Worker: ${worker.workerName}');
        print('📱 Phone: ${worker.workerPhone}');
        print('📧 Email: ${worker.workerEmail}');
        print('🆔 ID: ${worker.id}');
      } else {
        print('❌ Authentication failed - worker not found');
        print('💡 Make sure the worker exists and credentials are correct');
      }
    } catch (e) {
      print('❌ Error during authentication: $e');
    }
  }

  /// Clear all workers (use with caution!)
  static Future<void> clearAllWorkers() async {
    try {
      print('⚠️  Clearing all workers...');
      final workers = await _workerService.getAllWorkers();
      
      for (final worker in workers) {
        final success = await _workerService.deleteWorker(worker.id);
        if (success) {
          print('🗑️  Deleted worker: ${worker.workerName}');
        } else {
          print('❌ Failed to delete worker: ${worker.workerName}');
        }
      }
      
      print('✅ All workers cleared');
    } catch (e) {
      print('❌ Error clearing workers: $e');
    }
  }
}
