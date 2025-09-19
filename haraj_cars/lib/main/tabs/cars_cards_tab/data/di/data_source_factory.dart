// data_source_factory.dart - Factory for creating data sources

import '../config/data_source_config.dart';
import '../datasources/car_data_source.dart';
import '../datasources/supabase_car_data_source.dart';
import '../datasources/firebase_car_data_source.dart';
import '../datasources/sqlite_car_data_source.dart';
import '../repositories/car_repository.dart';

/// Factory for creating data sources and repositories
class DataSourceFactory {
  static CarRepository? _repository;
  
  /// Get the car repository instance
  static CarRepository getRepository() {
    if (_repository == null) {
      _repository = _createRepository();
    }
    return _repository!;
  }
  
  /// Create repository based on current data source configuration
  static CarRepository _createRepository() {
    final dataSource = _createDataSource();
    
    return CarRepository(
      carDataSource: dataSource,
      adminDataSource: dataSource,
      userDataSource: dataSource,
      dashboardDataSource: dataSource,
    );
  }
  
  /// Create data source based on current configuration
  static dynamic _createDataSource() {
    switch (DataSourceConfig.currentDataSource) {
      case DataSourceType.supabase:
        return SupabaseCarDataSource();
      case DataSourceType.firebase:
        // TODO: Firebase implementation coming soon
        throw UnimplementedError('Firebase data source not implemented yet');
      case DataSourceType.sqlite:
        // TODO: SQLite implementation coming soon
        throw UnimplementedError('SQLite data source not implemented yet');
    }
  }
  
  /// Reset repository (useful when switching data sources)
  static void resetRepository() {
    _repository = null;
  }
  
  /// Switch data source and recreate repository
  static void switchDataSource(DataSourceType dataSourceType) {
    DataSourceConfig.setDataSource(dataSourceType);
    resetRepository();
  }
}
