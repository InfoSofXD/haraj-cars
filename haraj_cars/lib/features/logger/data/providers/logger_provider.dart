import '../../domain/repositories/logger_repository.dart';
import '../../domain/services/logger_service.dart';
import '../repositories/logger_repository_impl.dart';
import '../../../../core/services/auth_service.dart';

class LoggerProvider {
  static LoggerService? _instance;
  static LoggerRepository? _repository;

  static LoggerService get instance {
    if (_instance == null) {
      _repository ??= LoggerRepositoryImpl();
      _instance = LoggerService(_repository!, AuthService());
    }
    return _instance!;
  }

  static void reset() {
    _instance = null;
    _repository = null;
  }
}
