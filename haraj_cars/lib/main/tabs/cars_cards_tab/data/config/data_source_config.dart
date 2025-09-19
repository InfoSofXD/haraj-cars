// data_source_config.dart - Configuration for data source selection

enum DataSourceType {
  supabase,
  firebase,
  sqlite,
}

class DataSourceConfig {
  static DataSourceType _currentDataSource = DataSourceType.supabase;
  
  /// Get the current data source type
  static DataSourceType get currentDataSource => _currentDataSource;
  
  /// Set the data source type
  static void setDataSource(DataSourceType dataSource) {
    _currentDataSource = dataSource;
  }
  
  /// Get data source type from string
  static DataSourceType fromString(String source) {
    switch (source.toLowerCase()) {
      case 'supabase':
        return DataSourceType.supabase;
      case 'firebase':
        return DataSourceType.firebase;
      case 'sqlite':
        return DataSourceType.sqlite;
      default:
        return DataSourceType.supabase; // Default fallback
    }
  }
  
  /// Convert data source type to string
  static String toTypeString(DataSourceType source) {
    switch (source) {
      case DataSourceType.supabase:
        return 'supabase';
      case DataSourceType.firebase:
        return 'firebase';
      case DataSourceType.sqlite:
        return 'sqlite';
    }
  }
}
