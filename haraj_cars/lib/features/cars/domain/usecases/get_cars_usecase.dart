import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../models/car.dart';
import '../entities/car_entity.dart';
import '../repositories/cars_repository.dart';

/// Use case for getting cars with filters
class GetCarsUseCase {
  final CarsRepository repository;

  GetCarsUseCase(this.repository);

  Future<Either<Failure, List<Car>>> call({
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
    // Validate pagination parameters
    if (page < 1) {
      return const Left(ValidationFailure('Page must be greater than 0'));
    }

    if (limit < 1 || limit > 100) {
      return const Left(ValidationFailure('Limit must be between 1 and 100'));
    }

    // Validate price range
    if (minPrice != null && minPrice < 0) {
      return const Left(ValidationFailure('Minimum price cannot be negative'));
    }

    if (maxPrice != null && maxPrice < 0) {
      return const Left(ValidationFailure('Maximum price cannot be negative'));
    }

    if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
      return const Left(ValidationFailure('Minimum price cannot be greater than maximum price'));
    }

    // Validate year range
    if (minYear != null && minYear < 1900) {
      return const Left(ValidationFailure('Minimum year must be 1900 or later'));
    }

    if (maxYear != null && maxYear > DateTime.now().year + 1) {
      return const Left(ValidationFailure('Maximum year cannot be in the future'));
    }

    if (minYear != null && maxYear != null && minYear > maxYear) {
      return const Left(ValidationFailure('Minimum year cannot be greater than maximum year'));
    }

    return await repository.getCars(
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
  }
}
