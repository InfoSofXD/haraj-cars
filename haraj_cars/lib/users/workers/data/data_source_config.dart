import 'worker_data_source.dart';
import 'supabase_worker_data_source.dart';

/// Configuration class to easily switch between different data sources
enum DataSourceType {
  supabase,
  // Add more data sources as needed (firebase, etc.)
}

class DataSourceConfig {
  static DataSourceType _currentDataSource = DataSourceType.supabase;

  /// Get the current data source type
  static DataSourceType get currentDataSource => _currentDataSource;

  /// Set the data source type
  static void setDataSource(DataSourceType type) {
    _currentDataSource = type;
  }

  /// Create a data source instance based on the current configuration
  static WorkerDataSource createDataSource() {
    switch (_currentDataSource) {
      case DataSourceType.supabase:
        return SupabaseWorkerDataSource();
      default:
        return SupabaseWorkerDataSource(); // Default fallback
    }
  }

  /// Switch to Supabase
  static void useSupabase() {
    setDataSource(DataSourceType.supabase);
  }
}

/// Example usage:
/// 
/// // To switch to Supabase:
/// DataSourceConfig.useSupabase();
/// 
/// // To get a data source instance:
/// final dataSource = DataSourceConfig.createDataSource();
/// 
/// // To add Firebase support later:
/// // 1. Install cloud_firestore package
/// // 2. Create FirebaseWorkerDataSource class
/// // 3. Add firebase to DataSourceType enum
/// // 4. Add case in createDataSource() method
