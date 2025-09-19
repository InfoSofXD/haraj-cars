// car_data_source.dart - Abstract interface for car data operations

import 'dart:typed_data';
import '../../../../../models/car.dart';

/// Abstract interface for car data operations
/// This allows switching between different data sources (Supabase, Firebase, SQLite)
abstract class CarDataSource {
  /// Get all cars
  Future<List<Car>> getCars();
  
  /// Search cars by query
  Future<List<Car>> searchCars(String query);
  
  /// Filter cars by price range
  Future<List<Car>> filterCarsByPrice(double minPrice, double maxPrice);
  
  /// Add a new car
  Future<bool> addCar(Car car);
  
  /// Update an existing car
  Future<bool> updateCar(Car car);
  
  /// Update car status only
  Future<bool> updateCarStatus(String carId, int status);
  
  /// Delete a car
  Future<bool> deleteCar(String carId);
  
  /// Upload image and return URL
  Future<String?> uploadImage(Uint8List imageBytes, String fileName);
  
  /// Upload image from URL (for scraped images)
  Future<String?> uploadImageFromUrl(String imageUrl);
  
  /// Delete image
  Future<bool> deleteImage(String fileName);
}

/// Abstract interface for admin authentication
abstract class AdminDataSource {
  /// Authenticate admin user
  Future<bool> authenticateAdmin(String username, String password);
  
  /// Get admin count
  Future<int> getAdminCount();
  
  /// Get recent admins
  Future<List<Map<String, dynamic>>> getRecentAdmins({int limit = 5});
}

/// Abstract interface for user management
abstract class UserDataSource {
  /// Get user count
  Future<int> getUserCount();
  
  /// Get all users
  Future<List<Map<String, dynamic>>> getAllUsers();
  
  /// Get recent users
  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 5});
  
  /// Delete user account
  Future<bool> deleteUser(String userId);
}

/// Abstract interface for dashboard statistics
abstract class DashboardDataSource {
  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats();
  
  /// Get recent cars
  Future<List<Map<String, dynamic>>> getRecentCars({int limit = 5});
  
  /// Get recent posts
  Future<List<Map<String, dynamic>>> getRecentPosts({int limit = 5});
}
