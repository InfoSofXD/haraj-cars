import 'dart:typed_data';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../models/car.dart';
import '../entities/car_entity.dart';

/// Cars repository interface
abstract class CarsRepository {
  /// Get all cars with pagination
  Future<Either<Failure, List<Car>>> getCars({
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

  /// Get car by ID
  Future<Either<Failure, Car>> getCarById(String carId);

  /// Search cars by query
  Future<Either<Failure, List<Car>>> searchCars({
    required String query,
    int page = 1,
    int limit = 20,
  });

  /// Filter cars by criteria
  Future<Either<Failure, List<Car>>> filterCars({
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

  /// Add new car (Super Admin and Worker only)
  Future<Either<Failure, Car>> addCar({
    required Car car,
  });

  /// Update car (Super Admin and Worker only)
  Future<Either<Failure, Car>> updateCar({
    required Car car,
  });

  /// Update car status (Super Admin and Worker only)
  Future<Either<Failure, Car>> updateCarStatus({
    required String carId,
    required CarStatus status,
  });

  /// Delete car (Super Admin only)
  Future<Either<Failure, void>> deleteCar({
    required String carId,
  });

  /// Upload car image
  Future<Either<Failure, String>> uploadCarImage({
    required Uint8List imageBytes,
    required String fileName,
  });

  /// Delete car image
  Future<Either<Failure, void>> deleteCarImage({
    required String fileName,
  });

  /// Get car statistics (Super Admin and Worker only)
  Future<Either<Failure, Map<String, dynamic>>> getCarStatistics();

  /// Get recent cars
  Future<Either<Failure, List<Car>>> getRecentCars({
    int limit = 5,
  });

  /// Get cars by user (for workers to see their cars)
  Future<Either<Failure, List<Car>>> getCarsByUser({
    required String userId,
    int page = 1,
    int limit = 20,
  });
}
