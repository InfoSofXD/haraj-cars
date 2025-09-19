# Data Layer Architecture

This data layer provides a clean abstraction for data operations, allowing you to easily switch between different data sources (Supabase, Firebase, SQLite) without changing your business logic.

## Architecture Overview

```
lib/data/
├── config/
│   └── data_source_config.dart          # Configuration for data source selection
├── datasources/
│   ├── car_data_source.dart             # Abstract interfaces for data operations
│   ├── supabase_car_data_source.dart    # Supabase implementation ✅
│   ├── firebase_car_data_source.dart    # Firebase implementation (Coming Soon)
│   └── sqlite_car_data_source.dart     # SQLite implementation (Coming Soon)
├── di/
│   └── data_source_factory.dart        # Dependency injection factory
├── repositories/
│   └── car_repository.dart              # Repository pattern implementation
└── ui/
    └── data_source_config_screen.dart   # UI for switching data sources
```

## Current Status

- ✅ **Supabase**: Fully implemented and working
- 🚧 **Firebase**: Implementation ready, but commented out (coming soon)
- 🚧 **SQLite**: Implementation ready, but commented out (coming soon)

## How to Use

### 1. Using the Repository in Your Code

```dart
import 'package:haraj/data/di/data_source_factory.dart';

// Get the repository instance
final repository = DataSourceFactory.getRepository();

// Use it for car operations
final cars = await repository.getCars();
final success = await repository.addCar(car);
```

### 2. Switching Data Sources

```dart
import 'package:haraj/data/config/data_source_config.dart';
import 'package:haraj/data/di/data_source_factory.dart';

// Switch to Supabase (currently the only working option)
DataSourceFactory.switchDataSource(DataSourceType.supabase);
```

### 3. Configuration Screen

Navigate to the `DataSourceConfigScreen` to switch data sources through the UI:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DataSourceConfigScreen(),
  ),
);
```

## Benefits

1. **Separation of Concerns**: Business logic is separated from data access
2. **Easy Switching**: Change data sources without modifying business logic
3. **Testability**: Easy to mock data sources for testing
4. **Future-Proof**: Ready for Firebase and SQLite implementations
5. **Clean Architecture**: Follows repository pattern and dependency injection

## Adding New Data Sources

When you're ready to implement Firebase or SQLite:

1. Uncomment the implementation files
2. Update the `data_source_factory.dart` to include the new cases
3. Update the configuration screen to enable the new options
4. Test thoroughly before switching

## Current Implementation

The `CreateUpdateCarLogic` has been updated to use the repository pattern instead of directly calling Supabase. This means your car creation/update functionality will work seamlessly regardless of which data source is selected.
