import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../models/car.dart';
import '../entities/car_entity.dart';
import '../repositories/cars_repository.dart';

/// Use case for adding a new car (Super Admin and Worker only)
class AddCarUseCase {
  final CarsRepository repository;

  AddCarUseCase(this.repository);

  Future<Either<Failure, Car>> call({
    required Car car,
  }) async {
    // Validate car data
    final validationResult = _validateCar(car);
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await repository.addCar(car: car);
  }

  ValidationFailure? _validateCar(Car car) {
    if (car.description.isEmpty) {
      return const ValidationFailure('Description cannot be empty');
    }

    if (car.description.length > 1000) {
      return const ValidationFailure('Description cannot exceed 1000 characters');
    }

    if (car.price <= 0) {
      return const ValidationFailure('Price must be greater than 0');
    }

    if (car.brand.isEmpty) {
      return const ValidationFailure('Brand cannot be empty');
    }

    if (car.model.isEmpty) {
      return const ValidationFailure('Model cannot be empty');
    }

    if (car.year < 1900 || car.year > DateTime.now().year + 1) {
      return const ValidationFailure('Year must be between 1900 and next year');
    }

    if (car.mileage < 0) {
      return const ValidationFailure('Mileage cannot be negative');
    }

    if (car.transmission.isEmpty) {
      return const ValidationFailure('Transmission cannot be empty');
    }

    if (car.fuelType.isEmpty) {
      return const ValidationFailure('Fuel type cannot be empty');
    }

    if (car.engineSize.isEmpty) {
      return const ValidationFailure('Engine size cannot be empty');
    }

    if (car.horsepower <= 0) {
      return const ValidationFailure('Horsepower must be greater than 0');
    }

    if (car.driveType.isEmpty) {
      return const ValidationFailure('Drive type cannot be empty');
    }

    if (car.exteriorColor.isEmpty) {
      return const ValidationFailure('Exterior color cannot be empty');
    }

    if (car.interiorColor.isEmpty) {
      return const ValidationFailure('Interior color cannot be empty');
    }

    if (car.doors <= 0) {
      return const ValidationFailure('Number of doors must be greater than 0');
    }

    if (car.seats <= 0) {
      return const ValidationFailure('Number of seats must be greater than 0');
    }

    if (car.contact.isEmpty) {
      return const ValidationFailure('Contact information cannot be empty');
    }

    if (car.contact.length > 20) {
      return const ValidationFailure('Contact information cannot exceed 20 characters');
    }

    return null;
  }
}
