// supabase_service.dart

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';

class SupabaseService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // Get all cars
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

  // Search cars by title or description
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

  // Filter cars by price range
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

  // Add new car
  Future<bool> addCar(Car car) async {
    try {
      print('SupabaseService: Adding car with data: ${car.toJson()}');

      // For new cars, we don't want to include id, car_id, or timestamps
      final insertData = {
        'description': car.description,
        'price': car.price,
        'brand': car.brand,
        'model': car.model,
        'year': car.year,
        'mileage': car.mileage,
        'transmission': car.transmission,
        'fuel_type': car.fuelType,
        'engine': car.engineSize,
        'horsepower': car.horsepower,
        'drive_type': car.driveType,
        'exterior_color': car.exteriorColor,
        'interior_color': car.interiorColor,
        'doors': car.doors,
        'seats': car.seats,
        'contact': car.contact,
        'vin': car.vin,
        'show_at': car.showAt?.toIso8601String(),
        'un_show_at': car.unShowAt?.toIso8601String(),
        'auction_start_at': car.auctionStartAt?.toIso8601String(),
        'auction_end_at': car.auctionEndAt?.toIso8601String(),
        'delete_at': car.deleteAt?.toIso8601String(),
      };

      // Only include image if it exists
      if (car.mainImage != null && car.mainImage!.isNotEmpty) {
        insertData['main_image'] = car.mainImage!;
      }

      if (car.otherImages != null && car.otherImages!.isNotEmpty) {
        insertData['other_images'] = car.otherImages!;
      }

      print('SupabaseService: Inserting data: $insertData');

      await _supabase.from('cars').insert(insertData);
      return true;
    } catch (e) {
      print('Error adding car: $e');
      return false;
    }
  }

  // Update car
  Future<bool> updateCar(Car car) async {
    try {
      print('SupabaseService: Updating car with data: ${car.toJson()}');

      // For updates, we need to include the car_id but not the id
      final updateData = {
        'description': car.description,
        'price': car.price,
        'brand': car.brand,
        'model': car.model,
        'year': car.year,
        'mileage': car.mileage,
        'transmission': car.transmission,
        'fuel_type': car.fuelType,
        'engine': car.engineSize,
        'horsepower': car.horsepower,
        'drive_type': car.driveType,
        'exterior_color': car.exteriorColor,
        'interior_color': car.interiorColor,
        'doors': car.doors,
        'seats': car.seats,
        'contact': car.contact,
        'vin': car.vin,
        'status': car.status,
        'show_at': car.showAt?.toIso8601String(),
        'un_show_at': car.unShowAt?.toIso8601String(),
        'auction_start_at': car.auctionStartAt?.toIso8601String(),
        'auction_end_at': car.auctionEndAt?.toIso8601String(),
        'delete_at': car.deleteAt?.toIso8601String(),
        'updated_at': car.updatedAt.toIso8601String(),
      };

      // Only include image if it exists
      if (car.mainImage != null && car.mainImage!.isNotEmpty) {
        updateData['main_image'] = car.mainImage!;
      }

      if (car.otherImages != null && car.otherImages!.isNotEmpty) {
        updateData['other_images'] = car.otherImages!;
      }

      print('SupabaseService: Updating data: $updateData');

      await _supabase.from('cars').update(updateData).eq('car_id', car.carId);
      return true;
    } catch (e) {
      print('Error updating car: $e');
      return false;
    }
  }

  // Update car status only
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

  // Delete car
  Future<bool> deleteCar(String carId) async {
    try {
      await _supabase.from('cars').delete().eq('car_id', carId);
      return true;
    } catch (e) {
      print('Error deleting car: $e');
      return false;
    }
  }

  // Admin authentication
  Future<bool> authenticateAdmin(String username, String password) async {
    try {
      print('SupabaseService: Authenticating admin with username: $username');

      final response = await _supabase
          .from('admin')
          .select()
          .eq('username', username)
          .eq('password', password);

      print('SupabaseService: Response received: $response');

      // Check if we got any results
      if (response.isNotEmpty) {
        print('SupabaseService: Admin authentication successful');
        return true;
      }
      print('SupabaseService: No admin user found with these credentials');
      return false;
    } catch (e) {
      print('SupabaseService: Error authenticating admin: $e');
      return false;
    }
  }

  // Upload image to Supabase storage
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

  // Store image URL directly (no upload needed for scraped images)
  Future<String?> uploadImageFromUrl(String imageUrl) async {
    // For scraped images, we just return the original URL
    // This avoids the complexity of downloading and re-uploading
    return imageUrl;
  }

  // Delete image from Supabase storage
  Future<bool> deleteImage(String fileName) async {
    try {
      await _supabase.storage.from('car-images').remove([fileName]);
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Test method to check admin table
  Future<void> testAdminTable() async {
    try {
      print('SupabaseService: Testing admin table...');
      final response = await _supabase.from('admin').select();
      print('SupabaseService: Admin table response: $response');
    } catch (e) {
      print('SupabaseService: Error testing admin table: $e');
    }
  }

  // Get user count from simple database function
  Future<int> getUserCount() async {
    try {
      print('SupabaseService: Getting user count...');
      final response = await _supabase.rpc('get_simple_user_count');
      final userCount = response as int;
      print('SupabaseService: Found $userCount users');
      return userCount;
    } catch (e) {
      print('SupabaseService: Error getting user count: $e');
      return 0;
    }
  }

  // Get all users from simple database function
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('SupabaseService: Getting all users...');
      final response = await _supabase.rpc('get_all_users');
      final allUsers = List<Map<String, dynamic>>.from(response);
      print('SupabaseService: Found ${allUsers.length} users');
      return allUsers;
    } catch (e) {
      print('SupabaseService: Error getting all users: $e');
      return [];
    }
  }

  // Get recent users (first 5 from all users)
  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 5}) async {
    try {
      final allUsers = await getAllUsers();
      final recentUsers = allUsers.take(limit).toList();
      print('SupabaseService: Found ${recentUsers.length} recent users');
      return recentUsers;
    } catch (e) {
      print('SupabaseService: Error getting recent users: $e');
      return [];
    }
  }

  // Get car statistics from database function
  Future<Map<String, dynamic>> getCarStatistics() async {
    try {
      print(
          'SupabaseService: Getting car statistics from database function...');
      final response = await _supabase.rpc('get_car_statistics');
      final stats = response as Map<String, dynamic>;

      print(
          'SupabaseService: Car statistics - Total: ${stats['total_cars']}, Available: ${stats['available_cars']}, Auction: ${stats['auction_cars']}, Sold: ${stats['sold_cars']}, Unavailable: ${stats['unavailable_cars']}, Avg Price: ${stats['avg_price']}');

      return {
        'totalCars': stats['total_cars'] ?? 0,
        'availableCars': stats['available_cars'] ?? 0,
        'auctionCars': stats['auction_cars'] ?? 0,
        'soldCars': stats['sold_cars'] ?? 0,
        'unavailableCars': stats['unavailable_cars'] ?? 0,
        'avgPrice': (stats['avg_price'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      print('SupabaseService: Error getting car statistics: $e');
      return {
        'totalCars': 0,
        'availableCars': 0,
        'auctionCars': 0,
        'soldCars': 0,
        'unavailableCars': 0,
        'avgPrice': 0,
      };
    }
  }

  // Get recent cars from database function
  Future<List<Map<String, dynamic>>> getRecentCars({int limit = 5}) async {
    try {
      print('SupabaseService: Getting recent cars from database function...');
      final response = await _supabase
          .rpc('get_recent_cars', params: {'limit_count': limit});
      final recentCars = List<Map<String, dynamic>>.from(response);
      print('SupabaseService: Found ${recentCars.length} recent cars');
      return recentCars;
    } catch (e) {
      print('SupabaseService: Error getting recent cars: $e');
      return [];
    }
  }

  // Get admin count from database function
  Future<int> getAdminCount() async {
    try {
      print('SupabaseService: Getting admin count from database function...');
      final response = await _supabase.rpc('get_admin_count');
      final adminCount = response as int;
      print('SupabaseService: Found $adminCount admins');
      return adminCount;
    } catch (e) {
      print('SupabaseService: Error getting admin count: $e');
      return 0;
    }
  }

  // Get recent admins from database function
  Future<List<Map<String, dynamic>>> getRecentAdmins({int limit = 5}) async {
    try {
      print('SupabaseService: Getting recent admins from database function...');
      final response = await _supabase
          .rpc('get_recent_admins', params: {'limit_count': limit});
      final recentAdmins = List<Map<String, dynamic>>.from(response);
      print('SupabaseService: Found ${recentAdmins.length} recent admins');
      return recentAdmins;
    } catch (e) {
      print('SupabaseService: Error getting recent admins: $e');
      return [];
    }
  }

  // Get recent posts from database function
  Future<List<Map<String, dynamic>>> getRecentPosts({int limit = 5}) async {
    try {
      print('SupabaseService: Getting recent posts from database function...');
      final response = await _supabase
          .rpc('get_recent_posts', params: {'limit_count': limit});
      final recentPosts = List<Map<String, dynamic>>.from(response);
      print('SupabaseService: Found ${recentPosts.length} recent posts');
      return recentPosts;
    } catch (e) {
      print('SupabaseService: Error getting recent posts: $e');
      return [];
    }
  }

  // Delete user account (admin only)
  Future<bool> deleteUser(String userId) async {
    try {
      print('SupabaseService: Deleting user $userId...');

      // Use the custom delete function
      final response = await _supabase.rpc('delete_user_account', params: {
        'user_id': userId,
      });

      print('SupabaseService: RPC response: $response');
      print('SupabaseService: Response type: ${response.runtimeType}');

      final success = response as bool;
      if (success) {
        print('SupabaseService: User deleted successfully');
        return true;
      } else {
        print(
            'SupabaseService: Failed to delete user - function returned false');
        return false;
      }
    } catch (e) {
      print('SupabaseService: Error deleting user: $e');
      print('SupabaseService: Error type: ${e.runtimeType}');
      return false;
    }
  }
}
