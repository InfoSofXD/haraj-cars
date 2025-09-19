import 'worker_data_source.dart';
import 'worker_model.dart';
import 'data_source_config.dart';

class WorkerService {
  static final WorkerService _instance = WorkerService._internal();
  factory WorkerService() => _instance;
  WorkerService._internal();

  // Use configuration to get the current data source
  WorkerDataSource get _dataSource => DataSourceConfig.createDataSource();

  /// Change the data source type (useful for switching between Supabase, Firebase, etc.)
  void setDataSourceType(DataSourceType type) {
    DataSourceConfig.setDataSource(type);
  }

  /// Get all workers
  Future<List<Worker>> getAllWorkers() async {
    return await _dataSource.getAllWorkers();
  }

  /// Get worker by ID
  Future<Worker?> getWorkerById(int id) async {
    return await _dataSource.getWorkerById(id);
  }

  /// Get worker by phone number
  Future<Worker?> getWorkerByPhone(String phone) async {
    return await _dataSource.getWorkerByPhone(phone);
  }

  /// Get worker by name
  Future<Worker?> getWorkerByName(String name) async {
    return await _dataSource.getWorkerByName(name);
  }

  /// Create a new worker
  Future<Worker?> createWorker({
    required String workerName,
    required String workerPhone,
    String? workerEmail,
    String? workerPassword,
  }) async {
    // Generate UUID if not provided
    final workerUuid = DateTime.now().millisecondsSinceEpoch.toString();
    
    final worker = Worker(
      id: 0, // Will be set by database
      createdAt: DateTime.now(),
      workerName: workerName,
      workerPhone: workerPhone,
      workerEmail: workerEmail,
      workerPassword: workerPassword,
      workerUuid: workerUuid,
    );

    return await _dataSource.createWorker(worker);
  }

  /// Update an existing worker
  Future<Worker?> updateWorker(Worker worker) async {
    return await _dataSource.updateWorker(worker);
  }

  /// Delete a worker
  Future<bool> deleteWorker(int id) async {
    return await _dataSource.deleteWorker(id);
  }

  /// Authenticate worker by phone and password
  Future<Worker?> authenticateWorker(String phone, String password) async {
    final worker = await _dataSource.authenticateWorker(phone, password);
    
    if (worker != null) {
      // Update last login time
      await _dataSource.updateLastLogin(worker.id);
    }
    
    return worker;
  }

  /// Authenticate worker by name and password
  Future<Worker?> authenticateWorkerByName(String name, String password) async {
    final worker = await _dataSource.authenticateWorkerByName(name, password);
    
    if (worker != null) {
      // Update last login time
      await _dataSource.updateLastLogin(worker.id);
    }
    
    return worker;
  }

  /// Search workers by name or phone
  Future<List<Worker>> searchWorkers(String query) async {
    return await _dataSource.searchWorkers(query);
  }

  /// Update worker's last login time
  Future<bool> updateLastLogin(int workerId) async {
    return await _dataSource.updateLastLogin(workerId);
  }
}
