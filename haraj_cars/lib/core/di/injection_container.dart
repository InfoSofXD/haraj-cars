import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Features
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/cars/data/datasources/cars_remote_datasource.dart';
import '../../features/cars/data/repositories/cars_repository_impl.dart';
import '../../features/cars/domain/repositories/cars_repository.dart';
import '../../features/cars/domain/usecases/get_cars_usecase.dart';
import '../../features/cars/domain/usecases/add_car_usecase.dart';
import '../../features/cars/presentation/bloc/cars_bloc.dart';

// Core
import '../constants/app_constants.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.baseUrl,
    anonKey: AppConstants.anonKey,
  );

  // External dependencies
  sl.registerLazySingleton(() => Supabase.instance.client);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  sl.registerLazySingleton<CarsRemoteDataSource>(
    () => CarsRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<CarsRepository>(
    () => CarsRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetCarsUseCase(sl()));
  sl.registerLazySingleton(() => AddCarUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => CarsBloc(
      getCarsUseCase: sl(),
      addCarUseCase: sl(),
      carsRepository: sl(),
    ),
  );
}
