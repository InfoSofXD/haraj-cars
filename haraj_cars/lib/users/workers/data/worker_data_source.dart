import 'worker_model.dart';

/// Abstract interface for worker data operations
/// This allows easy switching between different data sources (Supabase, Firebase, etc.)
abstract class WorkerDataSource {
  /// Get all workers
  Future<List<Worker>> getAllWorkers();
  
  /// Get worker by ID
  Future<Worker?> getWorkerById(int id);
  
  /// Get worker by phone number
  Future<Worker?> getWorkerByPhone(String phone);
  
  /// Get worker by name
  Future<Worker?> getWorkerByName(String name);
  
  /// Create a new worker
  Future<Worker?> createWorker(Worker worker);
  
  /// Update an existing worker
  Future<Worker?> updateWorker(Worker worker);
  
  /// Delete a worker
  Future<bool> deleteWorker(int id);
  
  /// Authenticate worker by phone and password
  Future<Worker?> authenticateWorker(String phone, String password);
  
  /// Authenticate worker by name and password
  Future<Worker?> authenticateWorkerByName(String name, String password);
  
  /// Update worker's last login time
  Future<bool> updateLastLogin(int workerId);
  
  /// Search workers by name or phone
  Future<List<Worker>> searchWorkers(String query);
}
