/// Application constants
class AppConstants {
  // API Constants
  static const String baseUrl = 'your-supabase-url';
  static const String anonKey = 'your-supabase-anon-key';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Database Tables
  static const String carsTable = 'cars';
  static const String usersTable = 'users';
  static const String adminTable = 'admin';
  static const String favoritesTable = 'favorites';
  
  // Car Status
  static const int carStatusAvailable = 1;
  static const int carStatusUnavailable = 2;
  static const int carStatusAuction = 3;
  static const int carStatusSold = 4;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Storage
  static const String carImagesBucket = 'car-images';
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxDescriptionLength = 1000;
  static const int maxContactLength = 20;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
}
