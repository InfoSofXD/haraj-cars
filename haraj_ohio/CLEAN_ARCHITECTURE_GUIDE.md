# 🏗️ Clean Architecture Guide for Haraj Cars

## Overview

This document outlines the clean architecture implementation for the Haraj Cars Flutter application, designed to support three distinct user types with proper separation of concerns and maintainable code structure.

## 🎯 User Types & Permissions

### 1. **Super Admin**
- **Full Access**: Complete control over the system
- **Permissions**: 
  - Manage all users (create, edit, delete)
  - Manage all cars (add, edit, delete)
  - Access admin analytics and reports
  - System configuration and settings

### 2. **Worker**
- **Limited Management**: Can manage cars but not users
- **Permissions**:
  - Add new cars
  - Edit existing cars
  - Update car status
  - View analytics for cars
  - Cannot delete cars or manage users

### 3. **Client**
- **Read-Only Access**: Browse and favorite cars
- **Permissions**:
  - View all available cars
  - Search and filter cars
  - Add/remove cars from favorites
  - View car details
  - Cannot add, edit, or delete cars

## 🏛️ Architecture Layers

### 1. **Core Layer** (`lib/core/`)
Contains shared functionality and utilities used across the entire application.

```
core/
├── constants/          # App constants, user roles, API endpoints
├── errors/            # Custom exceptions and failures
├── navigation/        # App routing and navigation
├── di/               # Dependency injection setup
└── utils/            # Utility functions and extensions
```

### 2. **Features Layer** (`lib/features/`)
Each feature is self-contained with its own domain, data, and presentation layers.

```
features/
├── auth/             # Authentication feature
│   ├── data/         # Data layer (models, datasources, repositories)
│   ├── domain/       # Domain layer (entities, repositories, usecases)
│   └── presentation/ # Presentation layer (pages, widgets, blocs)
├── cars/             # Cars management feature
├── favorites/        # Favorites feature
├── admin/            # Admin panel feature
└── worker/           # Worker panel feature
```

### 3. **Shared Layer** (`lib/shared/`)
Reusable components and services shared across features.

```
shared/
├── widgets/          # Reusable UI components
├── themes/           # App theming and styling
└── services/         # Shared services
```

## 🔄 Data Flow

### Clean Architecture Flow:
1. **UI** → **Bloc** → **Use Case** → **Repository** → **Data Source** → **External API**
2. **External API** → **Data Source** → **Repository** → **Use Case** → **Bloc** → **UI**

### Example: Adding a Car (Worker)
```
WorkerDashboard → CarsBloc → AddCarUseCase → CarsRepository → CarsRemoteDataSource → Supabase
```

## 🛠️ Key Components

### 1. **Entities** (Domain Layer)
Pure Dart classes representing business objects:
- `UserEntity`: User information and role
- `CarEntity`: Car data and status
- `FavoriteEntity`: User's favorite cars

### 2. **Use Cases** (Domain Layer)
Business logic implementation:
- `SignInUseCase`: Handle user authentication
- `AddCarUseCase`: Validate and add new cars
- `GetCarsUseCase`: Retrieve cars with filters

### 3. **Repositories** (Domain Layer)
Abstract interfaces defining data operations:
- `AuthRepository`: Authentication operations
- `CarsRepository`: Car management operations
- `FavoritesRepository`: Favorites management

### 4. **Data Sources** (Data Layer)
Concrete implementations for data access:
- `AuthRemoteDataSource`: Supabase authentication
- `CarsRemoteDataSource`: Supabase car operations
- `FavoritesRemoteDataSource`: Supabase favorites

### 5. **Blocs** (Presentation Layer)
State management using BLoC pattern:
- `AuthBloc`: Authentication state management
- `CarsBloc`: Car operations state management
- `FavoritesBloc`: Favorites state management

## 🔐 Authentication & Authorization

### Role-Based Access Control
```dart
enum UserRole {
  superAdmin('super_admin', 'Super Admin'),
  worker('worker', 'Worker'),
  client('client', 'Client');
}

// Permission checks
bool get canManageCars => role == UserRole.superAdmin || role == UserRole.worker;
bool get canAccessAdminPanel => role == UserRole.superAdmin;
bool get canManageUsers => role == UserRole.superAdmin;
```

### Authentication Flow
1. **Sign In**: Email/Password → Supabase Auth → User Entity
2. **Admin Sign In**: Username/Password → Admin Table → Super Admin Entity
3. **Role Assignment**: Database lookup → Role-based permissions

## 📱 UI Structure

### Navigation Based on User Role
```dart
switch (user.role) {
  case UserRole.superAdmin:
    return AdminDashboardPage();
  case UserRole.worker:
    return WorkerDashboardPage();
  case UserRole.client:
    return ClientHomePage();
}
```

### Feature-Specific UI
- **Client**: Browse cars, favorites, profile
- **Worker**: Dashboard, manage cars, add cars, analytics
- **Super Admin**: Full dashboard, user management, system settings

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR UNIQUE NOT NULL,
  username VARCHAR,
  full_name VARCHAR,
  phone_number VARCHAR,
  role VARCHAR NOT NULL DEFAULT 'client',
  profile_image_url VARCHAR,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Cars Table
```sql
CREATE TABLE cars (
  id SERIAL PRIMARY KEY,
  car_id VARCHAR UNIQUE NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL NOT NULL,
  brand VARCHAR NOT NULL,
  model VARCHAR NOT NULL,
  year INTEGER NOT NULL,
  mileage INTEGER NOT NULL,
  transmission VARCHAR NOT NULL,
  fuel_type VARCHAR NOT NULL,
  engine VARCHAR NOT NULL,
  horsepower INTEGER NOT NULL,
  drive_type VARCHAR NOT NULL,
  exterior_color VARCHAR NOT NULL,
  interior_color VARCHAR NOT NULL,
  doors INTEGER NOT NULL,
  seats INTEGER NOT NULL,
  main_image VARCHAR,
  other_images TEXT[],
  contact VARCHAR NOT NULL,
  vin VARCHAR,
  status INTEGER DEFAULT 1,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Favorites Table
```sql
CREATE TABLE favorites (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  car_id VARCHAR REFERENCES cars(car_id),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, car_id)
);
```

## 🚀 Getting Started

### 1. **Setup Dependencies**
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  get_it: ^7.6.4
  supabase_flutter: ^2.0.0
  equatable: ^2.0.5
```

### 2. **Initialize Dependency Injection**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // Initialize GetIt
  runApp(MyApp());
}
```

### 3. **Setup Bloc Providers**
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => sl<AuthBloc>()),
    BlocProvider(create: (_) => sl<CarsBloc>()),
    BlocProvider(create: (_) => sl<FavoritesBloc>()),
  ],
  child: MaterialApp.router(
    routerConfig: AppRouter.router,
  ),
)
```

## 📋 Implementation Checklist

### ✅ Completed
- [x] Core architecture setup
- [x] User roles and permissions
- [x] Domain layer (entities, repositories, use cases)
- [x] Data layer (models, datasources, repositories)
- [x] Presentation layer (blocs, pages, widgets)
- [x] Authentication system
- [x] Navigation structure
- [x] Dependency injection

### 🔄 Next Steps
- [ ] Implement remaining data sources
- [ ] Create UI components for each user type
- [ ] Add form validation
- [ ] Implement image upload functionality
- [ ] Add error handling and loading states
- [ ] Write unit tests
- [ ] Add integration tests

## 🎨 UI/UX Considerations

### Design Principles
1. **Role-Based UI**: Different interfaces for different user types
2. **Consistent Theming**: Unified design language across all screens
3. **Responsive Design**: Works on all screen sizes
4. **Accessibility**: Support for screen readers and accessibility features

### User Experience
- **Client**: Simple, intuitive car browsing experience
- **Worker**: Efficient car management tools
- **Super Admin**: Comprehensive admin dashboard with analytics

## 🔧 Development Guidelines

### Code Organization
1. **Feature-First**: Organize code by features, not by technical layers
2. **Single Responsibility**: Each class has one reason to change
3. **Dependency Inversion**: Depend on abstractions, not concretions
4. **Interface Segregation**: Small, focused interfaces

### Testing Strategy
1. **Unit Tests**: Test use cases and business logic
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test complete user flows
4. **Mocking**: Mock external dependencies

## 📚 Additional Resources

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/flutter)

---

This architecture provides a solid foundation for building a scalable, maintainable car marketplace application with proper separation of concerns and role-based access control.
