import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../models/car.dart';
import '../entities/favorite_entity.dart';

/// Favorites repository interface
abstract class FavoritesRepository {
  /// Get user's favorite cars
  Future<Either<Failure, List<Car>>> getFavoriteCars({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  /// Add car to favorites
  Future<Either<Failure, FavoriteEntity>> addToFavorites({
    required String userId,
    required String carId,
  });

  /// Remove car from favorites
  Future<Either<Failure, void>> removeFromFavorites({
    required String userId,
    required String carId,
  });

  /// Check if car is in favorites
  Future<Either<Failure, bool>> isFavorite({
    required String userId,
    required String carId,
  });

  /// Get favorite count for a car
  Future<Either<Failure, int>> getFavoriteCount({
    required String carId,
  });

  /// Clear all favorites for a user
  Future<Either<Failure, void>> clearAllFavorites({
    required String userId,
  });

  /// Get favorite entities (for admin purposes)
  Future<Either<Failure, List<FavoriteEntity>>> getFavoriteEntities({
    required String userId,
    int page = 1,
    int limit = 20,
  });
}
