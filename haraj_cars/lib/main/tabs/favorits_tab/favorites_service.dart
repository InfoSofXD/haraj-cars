import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/car.dart';
import '../../../features/logger/data/providers/logger_provider.dart';
import '../../../features/logger/domain/models/log_entry.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_cars';
  static FavoritesService? _instance;
  static SharedPreferences? _prefs;

  FavoritesService._internal();

  static Future<FavoritesService> getInstance() async {
    if (_instance == null) {
      _instance = FavoritesService._internal();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Add car to favorites
  Future<bool> addToFavorites(Car car) async {
    try {
      final favorites = await getFavoriteCars();
      final carJson = car.toJson();
      carJson['car_id'] = car.carId; // Ensure car_id is included

      // Check if car is already in favorites
      if (!favorites.any((favCar) => favCar.carId == car.carId)) {
        favorites.add(car);
        final success = await _saveFavorites(favorites);
        
        // Log favorite action
        if (success) {
          await LoggerProvider.instance.logFavoriteAction(
            action: LogAction.favoriteAdded,
            message: 'Added car to favorites: ${car.brand} ${car.model}',
            carId: car.carId,
            metadata: {
              'car_brand': car.brand,
              'car_model': car.model,
              'car_year': car.year,
              'car_price': car.price,
            },
          );
        }
        
        return success;
      }
      return true; // Already in favorites
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove car from favorites
  Future<bool> removeFromFavorites(String carId) async {
    try {
      final favorites = await getFavoriteCars();
      final carToRemove = favorites.firstWhere(
        (car) => car.carId == carId,
        orElse: () => Car(
          carId: carId,
          description: '',
          price: 0,
          brand: '',
          model: '',
          year: 0,
          mileage: 0,
          transmission: '',
          fuelType: '',
          engineSize: '',
          horsepower: 0,
          driveType: '',
          exteriorColor: '',
          interiorColor: '',
          doors: 0,
          seats: 0,
          contact: '',
          vin: '',
          status: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      favorites.removeWhere((car) => car.carId == carId);
      final success = await _saveFavorites(favorites);
      
      // Log favorite removal action
      if (success) {
        await LoggerProvider.instance.logFavoriteAction(
          action: LogAction.favoriteRemoved,
          message: 'Removed car from favorites: ${carToRemove.brand} ${carToRemove.model}',
          carId: carId,
          metadata: {
            'car_brand': carToRemove.brand,
            'car_model': carToRemove.model,
            'car_year': carToRemove.year,
            'car_price': carToRemove.price,
          },
        );
      }
      
      return success;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Get all favorite cars
  Future<List<Car>> getFavoriteCars() async {
    try {
      final favoritesJson = _prefs?.getStringList(_favoritesKey) ?? [];
      return favoritesJson.map((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return Car.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  // Check if car is in favorites
  Future<bool> isFavorite(String carId) async {
    try {
      final favorites = await getFavoriteCars();
      return favorites.any((car) => car.carId == carId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Car car) async {
    try {
      final isFav = await isFavorite(car.carId);
      if (isFav) {
        return await removeFromFavorites(car.carId);
      } else {
        return await addToFavorites(car);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      return await _prefs?.remove(_favoritesKey) ?? false;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  // Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      final favorites = await getFavoriteCars();
      return favorites.length;
    } catch (e) {
      print('Error getting favorites count: $e');
      return 0;
    }
  }

  // Save favorites to SharedPreferences
  Future<bool> _saveFavorites(List<Car> favorites) async {
    try {
      final favoritesJson = favorites.map((car) {
        final json = car.toJson();
        json['car_id'] = car.carId; // Ensure car_id is included
        return jsonEncode(json);
      }).toList();

      return await _prefs?.setStringList(_favoritesKey, favoritesJson) ?? false;
    } catch (e) {
      print('Error saving favorites: $e');
      return false;
    }
  }
}
