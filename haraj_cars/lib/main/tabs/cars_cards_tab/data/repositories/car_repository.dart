// car_repository.dart - Repository pattern for car data operations

import 'dart:typed_data';
import '../../../../../models/car.dart';
import '../datasources/car_data_source.dart';

/// Repository for car data operations
/// This acts as a single point of access for all car-related data operations
class CarRepository {
  final CarDataSource _carDataSource;
  final AdminDataSource _adminDataSource;
  final UserDataSource _userDataSource;
  final DashboardDataSource _dashboardDataSource;

  CarRepository({
    required CarDataSource carDataSource,
    required AdminDataSource adminDataSource,
    required UserDataSource userDataSource,
    required DashboardDataSource dashboardDataSource,
  }) : _carDataSource = carDataSource,
       _adminDataSource = adminDataSource,
       _userDataSource = userDataSource,
       _dashboardDataSource = dashboardDataSource;

  // Car operations
  Future<List<Car>> getCars() => _carDataSource.getCars();
  
  Future<List<Car>> searchCars(String query) => _carDataSource.searchCars(query);
  
  Future<List<Car>> filterCarsByPrice(double minPrice, double maxPrice) => 
      _carDataSource.filterCarsByPrice(minPrice, maxPrice);
  
  Future<bool> addCar(Car car) => _carDataSource.addCar(car);
  
  Future<bool> updateCar(Car car) => _carDataSource.updateCar(car);
  
  Future<bool> updateCarStatus(String carId, int status) => 
      _carDataSource.updateCarStatus(carId, status);
  
  Future<bool> deleteCar(String carId) => _carDataSource.deleteCar(carId);
  
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) => 
      _carDataSource.uploadImage(imageBytes, fileName);
  
  Future<String?> uploadImageFromUrl(String imageUrl) => 
      _carDataSource.uploadImageFromUrl(imageUrl);
  
  Future<bool> deleteImage(String fileName) => _carDataSource.deleteImage(fileName);

  // Admin operations
  Future<bool> authenticateAdmin(String username, String password) => 
      _adminDataSource.authenticateAdmin(username, password);
  
  Future<int> getAdminCount() => _adminDataSource.getAdminCount();
  
  Future<List<Map<String, dynamic>>> getRecentAdmins({int limit = 5}) => 
      _adminDataSource.getRecentAdmins(limit: limit);

  // User operations
  Future<int> getUserCount() => _userDataSource.getUserCount();
  
  Future<List<Map<String, dynamic>>> getAllUsers() => _userDataSource.getAllUsers();
  
  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 5}) => 
      _userDataSource.getRecentUsers(limit: limit);
  
  Future<bool> deleteUser(String userId) => _userDataSource.deleteUser(userId);

  // Dashboard operations
  Future<Map<String, dynamic>> getDashboardStats() => _dashboardDataSource.getDashboardStats();
  
  Future<List<Map<String, dynamic>>> getRecentCars({int limit = 5}) => 
      _dashboardDataSource.getRecentCars(limit: limit);
  
  Future<List<Map<String, dynamic>>> getRecentPosts({int limit = 5}) => 
      _dashboardDataSource.getRecentPosts(limit: limit);
}
