import 'dart:typed_data';
import 'package:haraj/features/cars/domain/entities/car_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../models/car.dart';

/// Remote data source for cars operations
abstract class CarsRemoteDataSource {
  Future<List<Car>> getCars({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? model,
    int? minYear,
    int? maxYear,
    CarStatus? status,
  });

  Future<Car> getCarById(String carId);

  Future<List<Car>> searchCars({
    required String query,
    int page = 1,
    int limit = 20,
  });

  Future<List<Car>> filterCars({
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? model,
    int? minYear,
    int? maxYear,
    CarStatus? status,
    int page = 1,
    int limit = 20,
  });

  Future<Car> addCar({required Car car});

  Future<Car> updateCar({required Car car});

  Future<Car> updateCarStatus({
    required String carId,
    required CarStatus status,
  });

  Future<void> deleteCar({required String carId});

  Future<String> uploadCarImage({
    required Uint8List imageBytes,
    required String fileName,
  });

  Future<void> deleteCarImage({required String fileName});

  Future<Map<String, dynamic>> getCarStatistics();

  Future<List<Car>> getRecentCars({int limit = 5});

  Future<List<Car>> getCarsByUser({
    required String userId,
    int page = 1,
    int limit = 20,
  });
}

/// Implementation of CarsRemoteDataSource using Supabase
class CarsRemoteDataSourceImpl implements CarsRemoteDataSource {
  final SupabaseClient supabaseClient;

  CarsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Car>> getCars({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? model,
    int? minYear,
    int? maxYear,
    CarStatus? status,
  }) async {
    try {
      // Build query step by step
      var query = supabaseClient.from(AppConstants.carsTable).select();

      // Apply search filter first
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('description.ilike.%$searchQuery%');
      }

      // Apply price filters
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      // Apply brand filter
      if (brand != null && brand.isNotEmpty) {
        query = query.eq('brand', brand);
      }

      // Apply model filter
      if (model != null && model.isNotEmpty) {
        query = query.eq('model', model);
      }

      // Apply year filters
      if (minYear != null) {
        query = query.gte('year', minYear);
      }
      if (maxYear != null) {
        query = query.lte('year', maxYear);
      }

      // Apply status filter
      if (status != null) {
        query = query.eq('status', status.value);
      }

      // Apply ordering and pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      
      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return response.map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get cars: ${e.toString()}');
    }
  }

  @override
  Future<Car> getCarById(String carId) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.carsTable)
          .select()
          .eq('car_id', carId)
          .single();

      return Car.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to get car: ${e.toString()}');
    }
  }

  @override
  Future<List<Car>> searchCars({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await supabaseClient
          .from(AppConstants.carsTable)
          .select()
          .or('description.ilike.%$query%')
          .order('created_at', ascending: false)
          .range(from, to);

      return response.map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to search cars: ${e.toString()}');
    }
  }

  @override
  Future<List<Car>> filterCars({
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? model,
    int? minYear,
    int? maxYear,
    CarStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = supabaseClient.from(AppConstants.carsTable).select();

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (brand != null && brand.isNotEmpty) {
        query = query.eq('brand', brand);
      }

      if (model != null && model.isNotEmpty) {
        query = query.eq('model', model);
      }

      if (minYear != null) {
        query = query.gte('year', minYear);
      }

      if (maxYear != null) {
        query = query.lte('year', maxYear);
      }

      if (status != null) {
        query = query.eq('status', status.value);
      }

      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return response.map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to filter cars: ${e.toString()}');
    }
  }

  @override
  Future<Car> addCar({required Car car}) async {
    try {
      final carData = car.toJson();
      // Remove id and timestamps for new car
      carData.remove('id');
      carData.remove('created_at');
      carData.remove('updated_at');

      final response = await supabaseClient
          .from(AppConstants.carsTable)
          .insert(carData)
          .select()
          .single();

      return Car.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to add car: ${e.toString()}');
    }
  }

  @override
  Future<Car> updateCar({required Car car}) async {
    try {
      final carData = car.toJson();
      carData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabaseClient
          .from(AppConstants.carsTable)
          .update(carData)
          .eq('car_id', car.carId)
          .select()
          .single();

      return Car.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update car: ${e.toString()}');
    }
  }

  @override
  Future<Car> updateCarStatus({
    required String carId,
    required CarStatus status,
  }) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.carsTable)
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('car_id', carId)
          .select()
          .single();

      return Car.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update car status: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCar({required String carId}) async {
    try {
      await supabaseClient
          .from(AppConstants.carsTable)
          .delete()
          .eq('car_id', carId);
    } catch (e) {
      throw ServerException('Failed to delete car: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadCarImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final response = await supabaseClient.storage
          .from(AppConstants.carImagesBucket)
          .uploadBinary(fileName, imageBytes);

      if (response.isNotEmpty) {
        final imageUrl = supabaseClient.storage
            .from(AppConstants.carImagesBucket)
            .getPublicUrl(fileName);
        return imageUrl;
      }
      throw ServerException('Failed to upload image');
    } catch (e) {
      throw ServerException('Failed to upload image: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCarImage({required String fileName}) async {
    try {
      await supabaseClient.storage
          .from(AppConstants.carImagesBucket)
          .remove([fileName]);
    } catch (e) {
      throw ServerException('Failed to delete image: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getCarStatistics() async {
    try {
      final response = await supabaseClient.rpc('get_car_statistics');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ServerException('Failed to get car statistics: ${e.toString()}');
    }
  }

  @override
  Future<List<Car>> getRecentCars({int limit = 5}) async {
    try {
      final response = await supabaseClient
          .from(AppConstants.carsTable)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get recent cars: ${e.toString()}');
    }
  }

  @override
  Future<List<Car>> getCarsByUser({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await supabaseClient
          .from(AppConstants.carsTable)
          .select()
          .eq('created_by', userId)
          .order('created_at', ascending: false)
          .range(from, to);

      return response.map((json) => Car.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get cars by user: ${e.toString()}');
    }
  }
}
