// supabase_car_data_source.dart - Supabase implementation of car data source

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../models/car.dart';
import 'car_data_source.dart';

/// Supabase implementation of car data source
class SupabaseCarDataSource implements CarDataSource, AdminDataSource, UserDataSource, DashboardDataSource {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<List<Car>> getCars() async {
    try {
      final response = await _supabase
          .from('cars')
          .select()
          .order('created_at', ascending: false);

      return (response).map((json) {
        final car = Car.fromJson(json);
        return car;
      }).toList();
    } catch (e) {
      print('Error fetching cars: $e');
      return [];
    }
  }

  @override
  Future<List<Car>> searchCars(String query) async {
    try {
      final response = await _supabase
          .from('cars')
          .select()
          .or('description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response).map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      print('Error searching cars: $e');
      return [];
    }
  }

  @override
  Future<List<Car>> filterCarsByPrice(double minPrice, double maxPrice) async {
    try {
      final response = await _supabase
          .from('cars')
          .select()
          .gte('price', minPrice)
          .lte('price', maxPrice)
          .order('created_at', ascending: false);

      return (response).map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      print('Error filtering cars by price: $e');
      return [];
    }
  }

  @override
  Future<bool> addCar(Car car) async {
    try {
      print('SupabaseCarDataSource: Adding car with data: ${car.toJson()}');

      // For new cars, we don't want to include id, car_id, or timestamps
      final carData = car.toJson();
      carData.remove('id');
      carData.remove('car_id');
      carData.remove('created_at');
      carData.remove('updated_at');

      final response = await _supabase.from('cars').insert(carData);
      print('SupabaseCarDataSource: Car added successfully');
      return true;
    } catch (e) {
      print('SupabaseCarDataSource: Error adding car: $e');
      return false;
    }
  }

  @override
  Future<bool> updateCar(Car car) async {
    try {
      print('SupabaseCarDataSource: Updating car with data: ${car.toJson()}');

      final carData = car.toJson();
      carData.remove('id');
      carData.remove('car_id');
      carData.remove('created_at');

      await _supabase.from('cars').update(carData).eq('car_id', car.carId);
      print('SupabaseCarDataSource: Car updated successfully');
      return true;
    } catch (e) {
      print('SupabaseCarDataSource: Error updating car: $e');
      return false;
    }
  }

  @override
  Future<bool> updateCarStatus(String carId, int status) async {
    try {
      await _supabase.from('cars').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('car_id', carId);
      return true;
    } catch (e) {
      print('Error updating car status: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteCar(String carId) async {
    try {
      await _supabase.from('cars').delete().eq('car_id', carId);
      return true;
    } catch (e) {
      print('Error deleting car: $e');
      return false;
    }
  }

  @override
  Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      final response = await _supabase.storage
          .from('car-images')
          .uploadBinary(fileName, imageBytes);

      if (response.isNotEmpty) {
        final imageUrl =
            _supabase.storage.from('car-images').getPublicUrl(fileName);
        return imageUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Future<String?> uploadImageFromUrl(String imageUrl) async {
    // For scraped images, we just return the original URL
    // This avoids the complexity of downloading and re-uploading
    return imageUrl;
  }

  @override
  Future<bool> deleteImage(String fileName) async {
    try {
      await _supabase.storage.from('car-images').remove([fileName]);
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // AdminDataSource implementation
  @override
  Future<bool> authenticateAdmin(String username, String password) async {
    try {
      print('SupabaseCarDataSource: Authenticating admin with username: $username');

      final response = await _supabase
          .from('admin')
          .select()
          .eq('username', username)
          .eq('password', password);

      print('SupabaseCarDataSource: Response received: $response');

      // Check if we got any results
      if (response.isNotEmpty) {
        print('SupabaseCarDataSource: Admin authentication successful');
        return true;
      }
      print('SupabaseCarDataSource: No admin user found with these credentials');
      return false;
    } catch (e) {
      print('SupabaseCarDataSource: Error authenticating admin: $e');
      return false;
    }
  }

  @override
  Future<int> getAdminCount() async {
    try {
      print('SupabaseCarDataSource: Getting admin count from database function...');
      final response = await _supabase.rpc('get_admin_count');
      final adminCount = response as int;
      print('SupabaseCarDataSource: Found $adminCount admins');
      return adminCount;
    } catch (e) {
      print('SupabaseCarDataSource: Error getting admin count: $e');
      return 0;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentAdmins({int limit = 5}) async {
    try {
      print('SupabaseCarDataSource: Getting recent admins from database function...');
      final response = await _supabase
          .rpc('get_recent_admins', params: {'limit_count': limit});
      final recentAdmins = List<Map<String, dynamic>>.from(response);
      print('SupabaseCarDataSource: Found ${recentAdmins.length} recent admins');
      return recentAdmins;
    } catch (e) {
      print('SupabaseCarDataSource: Error getting recent admins: $e');
      return [];
    }
  }

  // UserDataSource implementation
  @override
  Future<int> getUserCount() async {
    try {
      print('SupabaseCarDataSource: Getting user count...');
      final response = await _supabase.rpc('get_simple_user_count');
      final userCount = response as int;
      print('SupabaseCarDataSource: Found $userCount users');
      return userCount;
    } catch (e) {
      print('SupabaseCarDataSource: Error getting user count: $e');
      return 0;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('SupabaseCarDataSource: Getting all users...');
      final response = await _supabase.rpc('get_all_users');
      final allUsers = List<Map<String, dynamic>>.from(response);
      print('SupabaseCarDataSource: Found ${allUsers.length} users');
      return allUsers;
    } catch (e) {
      print('SupabaseCarDataSource: Error getting all users: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 5}) async {
    try {
      print('SupabaseCarDataSource: Getting recent users...');
      final response = await _supabase
          .rpc('get_recent_users', params: {'limit_count': limit});
      final recentUsers = List<Map<String, dynamic>>.from(response);
      print('SupabaseCarDataSource: Found ${recentUsers.length} recent users');
      return recentUsers;
    } catch (e) {
      print('SupabaseCarDataSource: Error getting recent users: $e');
      return [];
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      print('SupabaseCarDataSource: Deleting user $userId...');

      // Use the custom delete function
      final response = await _supabase.rpc('delete_user_account', params: {
        'user_id': userId,
      });

      print('SupabaseCarDataSource: RPC response: $response');
      print('SupabaseCarDataSource: Response type: ${response.runtimeType}');

      final success = response as bool;
      if (success) {
        print('SupabaseCarDataSource: User deleted successfully');
        return true;
      } else {
        print('SupabaseCarDataSource: Failed to delete user - function returned false');
        return false;
      }
    } catch (e) {
      print('SupabaseCarDataSource: Error deleting user: $e');
      print('SupabaseCarDataSource: Error type: ${e.runtimeType}');
      return false;
    }
  }

  // DashboardDataSource implementation
  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('SupabaseCarDataSource: Getting dashboard stats...');
      final response = await _supabase.rpc('get_dashboard_stats');
      final stats = Map<String, dynamic>.from(response);
      print('SupabaseCarDataSource: Dashboard stats: $stats');
      return stats;
    } catch (e) {
      print('SupabaseCarDataSource: Error getting dashboard stats: $e');
      return {
        'totalCars': 0,
        'totalUsers': 0,
        'totalAdmins': 0,
        'availableCars': 0,
        'unavailableCars': 0,
        'avgPrice': 0,
      };
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentCars({int limit = 5}) async {
    try {
      print('SupabaseCarDataSource: Getting recent cars from database function...');
      final response = await _supabase
          .rpc('get_recent_cars', params: {'limit_count': limit});
      final recentCars = List<Map<String, dynamic>>.from(response);
      print('SupabaseCarDataSource: Found ${recentCars.length} recent cars');
      return recentCars;
    } catch (e) {
      print('SupabaseCarDataSource: Error getting recent cars: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentPosts({int limit = 5}) async {
    try {
      print('SupabaseCarDataSource: Getting recent posts from database function...');
      final response = await _supabase
          .rpc('get_recent_posts', params: {'limit_count': limit});
      final recentPosts = List<Map<String, dynamic>>.from(response);
      print('SupabaseCarDataSource: Found ${recentPosts.length} recent posts');
      return recentPosts;
    } catch (e) {
      print('SupabaseCarDataSource: Error getting recent posts: $e');
      return [];
    }
  }
}
