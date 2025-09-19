import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../models/car.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/usecases/get_cars_usecase.dart';
import '../../domain/usecases/add_car_usecase.dart';
import '../../domain/repositories/cars_repository.dart';

/// Cars events
abstract class CarsEvent {}

class LoadCarsRequested extends CarsEvent {
  final int page;
  final int limit;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final String? brand;
  final String? model;
  final int? minYear;
  final int? maxYear;
  final CarStatus? status;

  LoadCarsRequested({
    this.page = 1,
    this.limit = 20,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.brand,
    this.model,
    this.minYear,
    this.maxYear,
    this.status,
  });
}

class SearchCarsRequested extends CarsEvent {
  final String query;
  final int page;
  final int limit;

  SearchCarsRequested({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });
}

class FilterCarsRequested extends CarsEvent {
  final double? minPrice;
  final double? maxPrice;
  final String? brand;
  final String? model;
  final int? minYear;
  final int? maxYear;
  final CarStatus? status;
  final int page;
  final int limit;

  FilterCarsRequested({
    this.minPrice,
    this.maxPrice,
    this.brand,
    this.model,
    this.minYear,
    this.maxYear,
    this.status,
    this.page = 1,
    this.limit = 20,
  });
}

class AddCarRequested extends CarsEvent {
  final Car car;

  AddCarRequested({required this.car});
}

class UpdateCarRequested extends CarsEvent {
  final Car car;

  UpdateCarRequested({required this.car});
}

class UpdateCarStatusRequested extends CarsEvent {
  final String carId;
  final CarStatus status;

  UpdateCarStatusRequested({
    required this.carId,
    required this.status,
  });
}

class DeleteCarRequested extends CarsEvent {
  final String carId;

  DeleteCarRequested({required this.carId});
}

class LoadCarStatisticsRequested extends CarsEvent {}

class LoadRecentCarsRequested extends CarsEvent {
  final int limit;

  LoadRecentCarsRequested({this.limit = 5});
}

class RefreshCarsRequested extends CarsEvent {}

/// Cars states
abstract class CarsState {}

class CarsInitial extends CarsState {}

class CarsLoading extends CarsState {}

class CarsLoaded extends CarsState {
  final List<Car> cars;
  final int currentPage;
  final bool hasMoreData;
  final String? searchQuery;
  final Map<String, dynamic>? filters;

  CarsLoaded({
    required this.cars,
    required this.currentPage,
    required this.hasMoreData,
    this.searchQuery,
    this.filters,
  });
}

class CarsError extends CarsState {
  final String message;

  CarsError({required this.message});
}

class CarAdded extends CarsState {
  final Car car;

  CarAdded({required this.car});
}

class CarUpdated extends CarsState {
  final Car car;

  CarUpdated({required this.car});
}

class CarDeleted extends CarsState {
  final String carId;

  CarDeleted({required this.carId});
}

class CarStatisticsLoaded extends CarsState {
  final Map<String, dynamic> statistics;

  CarStatisticsLoaded({required this.statistics});
}

class RecentCarsLoaded extends CarsState {
  final List<Car> recentCars;

  RecentCarsLoaded({required this.recentCars});
}

/// Cars Bloc
class CarsBloc extends Bloc<CarsEvent, CarsState> {
  final GetCarsUseCase getCarsUseCase;
  final AddCarUseCase addCarUseCase;
  final CarsRepository carsRepository;

  CarsBloc({
    required this.getCarsUseCase,
    required this.addCarUseCase,
    required this.carsRepository,
  }) : super(CarsInitial()) {
    on<LoadCarsRequested>(_onLoadCarsRequested);
    on<SearchCarsRequested>(_onSearchCarsRequested);
    on<FilterCarsRequested>(_onFilterCarsRequested);
    on<AddCarRequested>(_onAddCarRequested);
    on<UpdateCarRequested>(_onUpdateCarRequested);
    on<UpdateCarStatusRequested>(_onUpdateCarStatusRequested);
    on<DeleteCarRequested>(_onDeleteCarRequested);
    on<LoadCarStatisticsRequested>(_onLoadCarStatisticsRequested);
    on<LoadRecentCarsRequested>(_onLoadRecentCarsRequested);
    on<RefreshCarsRequested>(_onRefreshCarsRequested);
  }

  Future<void> _onLoadCarsRequested(
    LoadCarsRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await getCarsUseCase(
      page: event.page,
      limit: event.limit,
      searchQuery: event.searchQuery,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      brand: event.brand,
      model: event.model,
      minYear: event.minYear,
      maxYear: event.maxYear,
      status: event.status,
    );

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (cars) => emit(CarsLoaded(
        cars: cars,
        currentPage: event.page,
        hasMoreData: cars.length == event.limit,
        searchQuery: event.searchQuery,
        filters: {
          'minPrice': event.minPrice,
          'maxPrice': event.maxPrice,
          'brand': event.brand,
          'model': event.model,
          'minYear': event.minYear,
          'maxYear': event.maxYear,
          'status': event.status,
        },
      )),
    );
  }

  Future<void> _onSearchCarsRequested(
    SearchCarsRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await carsRepository.searchCars(
      query: event.query,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (cars) => emit(CarsLoaded(
        cars: cars,
        currentPage: event.page,
        hasMoreData: cars.length == event.limit,
        searchQuery: event.query,
      )),
    );
  }

  Future<void> _onFilterCarsRequested(
    FilterCarsRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await carsRepository.filterCars(
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      brand: event.brand,
      model: event.model,
      minYear: event.minYear,
      maxYear: event.maxYear,
      status: event.status,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (cars) => emit(CarsLoaded(
        cars: cars,
        currentPage: event.page,
        hasMoreData: cars.length == event.limit,
        filters: {
          'minPrice': event.minPrice,
          'maxPrice': event.maxPrice,
          'brand': event.brand,
          'model': event.model,
          'minYear': event.minYear,
          'maxYear': event.maxYear,
          'status': event.status,
        },
      )),
    );
  }

  Future<void> _onAddCarRequested(
    AddCarRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await addCarUseCase(car: event.car);

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (car) => emit(CarAdded(car: car)),
    );
  }

  Future<void> _onUpdateCarRequested(
    UpdateCarRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await carsRepository.updateCar(car: event.car);

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (car) => emit(CarUpdated(car: car)),
    );
  }

  Future<void> _onUpdateCarStatusRequested(
    UpdateCarStatusRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await carsRepository.updateCarStatus(
      carId: event.carId,
      status: event.status,
    );

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (car) => emit(CarUpdated(car: car)),
    );
  }

  Future<void> _onDeleteCarRequested(
    DeleteCarRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await carsRepository.deleteCar(carId: event.carId);

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (_) => emit(CarDeleted(carId: event.carId)),
    );
  }

  Future<void> _onLoadCarStatisticsRequested(
    LoadCarStatisticsRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await carsRepository.getCarStatistics();

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (statistics) => emit(CarStatisticsLoaded(statistics: statistics)),
    );
  }

  Future<void> _onLoadRecentCarsRequested(
    LoadRecentCarsRequested event,
    Emitter<CarsState> emit,
  ) async {
    emit(CarsLoading());

    final result = await carsRepository.getRecentCars(limit: event.limit);

    result.fold(
      (failure) => emit(CarsError(message: failure.message)),
      (recentCars) => emit(RecentCarsLoaded(recentCars: recentCars)),
    );
  }

  Future<void> _onRefreshCarsRequested(
    RefreshCarsRequested event,
    Emitter<CarsState> emit,
  ) async {
    // Reload cars with current state parameters
    if (state is CarsLoaded) {
      final currentState = state as CarsLoaded;
      add(LoadCarsRequested(
        page: 1,
        limit: 20,
        searchQuery: currentState.searchQuery,
        minPrice: currentState.filters?['minPrice'],
        maxPrice: currentState.filters?['maxPrice'],
        brand: currentState.filters?['brand'],
        model: currentState.filters?['model'],
        minYear: currentState.filters?['minYear'],
        maxYear: currentState.filters?['maxYear'],
        status: currentState.filters?['status'],
      ));
    } else {
      add(LoadCarsRequested());
    }
  }
}
