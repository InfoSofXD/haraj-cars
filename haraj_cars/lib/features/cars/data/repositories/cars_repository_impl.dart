import 'dart:typed_data';

import 'package:haraj/features/cars/domain/entities/car_entity.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../models/car.dart';
import '../../domain/repositories/cars_repository.dart';
import '../datasources/cars_remote_datasource.dart';

/// Implementation of CarsRepository
class CarsRepositoryImpl implements CarsRepository {
  final CarsRemoteDataSource remoteDataSource;

  CarsRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    try {
      final cars = await remoteDataSource.getCars(
        page: page,
        limit: limit,
        searchQuery: searchQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
        brand: brand,
        model: model,
        minYear: minYear,
        maxYear: maxYear,
        status: status,
      );
      return Right(cars);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Car>> getCarById(String carId) async {
    try {
      final car = await remoteDataSource.getCarById(carId);
      return Right(car);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Car>>> searchCars({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final cars = await remoteDataSource.searchCars(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(cars);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
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
  }) async {
    try {
      final cars = await remoteDataSource.filterCars(
        minPrice: minPrice,
        maxPrice: maxPrice,
        brand: brand,
        model: model,
        minYear: minYear,
        maxYear: maxYear,
        status: status,
        page: page,
        limit: limit,
      );
      return Right(cars);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Car>> addCar({required Car car}) async {
    try {
      final addedCar = await remoteDataSource.addCar(car: car);
      return Right(addedCar);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Car>> updateCar({required Car car}) async {
    try {
      final updatedCar = await remoteDataSource.updateCar(car: car);
      return Right(updatedCar);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Car>> updateCarStatus({
    required String carId,
    required CarStatus status,
  }) async {
    try {
      final updatedCar = await remoteDataSource.updateCarStatus(
        carId: carId,
        status: status,
      );
      return Right(updatedCar);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCar({required String carId}) async {
    try {
      await remoteDataSource.deleteCar(carId: carId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCarImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final imageUrl = await remoteDataSource.uploadCarImage(
        imageBytes: imageBytes,
        fileName: fileName,
      );
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCarImage({required String fileName}) async {
    try {
      await remoteDataSource.deleteCarImage(fileName: fileName);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCarStatistics() async {
    try {
      final statistics = await remoteDataSource.getCarStatistics();
      return Right(statistics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Car>>> getRecentCars({int limit = 5}) async {
    try {
      final recentCars = await remoteDataSource.getRecentCars(limit: limit);
      return Right(recentCars);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Car>>> getCarsByUser({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final cars = await remoteDataSource.getCarsByUser(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(cars);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
