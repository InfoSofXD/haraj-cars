// // sqlite_car_data_source.dart - SQLite implementation of car data source

// import 'dart:typed_data';
// import 'dart:io';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../../models/car.dart';
// import 'car_data_source.dart';

// /// SQLite implementation of car data source
// class SqliteCarDataSource implements CarDataSource, AdminDataSource, UserDataSource, DashboardDataSource {
//   static Database? _database;
//   static const String _carsTable = 'cars';
//   static const String _adminsTable = 'admins';
//   static const String _usersTable = 'users';
//   static const String _postsTable = 'posts';

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final databasesPath = await getDatabasesPath();
//     final path = join(databasesPath, 'haraj_cars.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     // Create cars table
//     await db.execute('''
//       CREATE TABLE $_carsTable (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         car_id TEXT UNIQUE NOT NULL,
//         description TEXT,
//         price REAL NOT NULL,
//         brand TEXT NOT NULL,
//         model TEXT NOT NULL,
//         year INTEGER NOT NULL,
//         mileage INTEGER NOT NULL,
//         transmission TEXT NOT NULL,
//         fuel_type TEXT NOT NULL,
//         engine TEXT NOT NULL,
//         horsepower INTEGER NOT NULL,
//         drive_type TEXT NOT NULL,
//         exterior_color TEXT NOT NULL,
//         interior_color TEXT NOT NULL,
//         doors INTEGER NOT NULL,
//         seats INTEGER NOT NULL,
//         main_image TEXT,
//         other_images TEXT,
//         contact TEXT NOT NULL,
//         vin TEXT,
//         status INTEGER DEFAULT 1,
//         show_at TEXT,
//         un_show_at TEXT,
//         auction_start_at TEXT,
//         auction_end_at TEXT,
//         delete_at TEXT,
//         created_at TEXT NOT NULL,
//         updated_at TEXT NOT NULL
//       )
//     ''');

//     // Create admins table
//     await db.execute('''
//       CREATE TABLE $_adminsTable (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         username TEXT NOT NULL,
//         password TEXT NOT NULL,
//         created_at TEXT NOT NULL
//       )
//     ''');

//     // Create users table
//     await db.execute('''
//       CREATE TABLE $_usersTable (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         user_id TEXT UNIQUE NOT NULL,
//         email TEXT,
//         name TEXT,
//         created_at TEXT NOT NULL
//       )
//     ''');

//     // Create posts table
//     await db.execute('''
//       CREATE TABLE $_postsTable (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         post_id TEXT UNIQUE NOT NULL,
//         title TEXT NOT NULL,
//         content TEXT,
//         created_at TEXT NOT NULL
//       )
//     ''');
//   }

//   @override
//   Future<List<Car>> getCars() async {
//     try {
//       final db = await database;
//       final List<Map<String, dynamic>> maps = await db.query(
//         _carsTable,
//         orderBy: 'created_at DESC',
//       );

//       return maps.map((map) => Car.fromJson(_convertSqliteToJson(map))).toList();
//     } catch (e) {
//       print('Error fetching cars: $e');
//       return [];
//     }
//   }

//   @override
//   Future<List<Car>> searchCars(String query) async {
//     try {
//       final db = await database;
//       final List<Map<String, dynamic>> maps = await db.query(
//         _carsTable,
//         where: 'description LIKE ?',
//         whereArgs: ['%$query%'],
//         orderBy: 'created_at DESC',
//       );

//       return maps.map((map) => Car.fromJson(_convertSqliteToJson(map))).toList();
//     } catch (e) {
//       print('Error searching cars: $e');
//       return [];
//     }
//   }

//   @override
//   Future<List<Car>> filterCarsByPrice(double minPrice, double maxPrice) async {
//     try {
//       final db = await database;
//       final List<Map<String, dynamic>> maps = await db.query(
//         _carsTable,
//         where: 'price >= ? AND price <= ?',
//         whereArgs: [minPrice, maxPrice],
//         orderBy: 'created_at DESC',
//       );

//       return maps.map((map) => Car.fromJson(_convertSqliteToJson(map))).toList();
//     } catch (e) {
//       print('Error filtering cars by price: $e');
//       return [];
//     }
//   }

//   @override
//   Future<bool> addCar(Car car) async {
//     try {
//       print('SqliteCarDataSource: Adding car with data: ${car.toJson()}');

//       final db = await database;
//       final carData = car.toJson();
//       carData.remove('id');
//       carData.remove('car_id');
//       carData.remove('created_at');
//       carData.remove('updated_at');

//       // Convert other_images list to JSON string for SQLite
//       if (carData['other_images'] != null) {
//         carData['other_images'] = carData['other_images'].join(',');
//       }

//       carData['created_at'] = DateTime.now().toIso8601String();
//       carData['updated_at'] = DateTime.now().toIso8601String();

//       await db.insert(_carsTable, carData);
//       print('SqliteCarDataSource: Car added successfully');
//       return true;
//     } catch (e) {
//       print('SqliteCarDataSource: Error adding car: $e');
//       return false;
//     }
//   }

//   @override
//   Future<bool> updateCar(Car car) async {
//     try {
//       print('SqliteCarDataSource: Updating car with data: ${car.toJson()}');

//       final db = await database;
//       final carData = car.toJson();
//       carData.remove('id');
//       carData.remove('car_id');
//       carData.remove('created_at');

//       // Convert other_images list to JSON string for SQLite
//       if (carData['other_images'] != null) {
//         carData['other_images'] = carData['other_images'].join(',');
//       }

//       carData['updated_at'] = DateTime.now().toIso8601String();

//       await db.update(
//         _carsTable,
//         carData,
//         where: 'car_id = ?',
//         whereArgs: [car.carId],
//       );
//       print('SqliteCarDataSource: Car updated successfully');
//       return true;
//     } catch (e) {
//       print('SqliteCarDataSource: Error updating car: $e');
//       return false;
//     }
//   }

//   @override
//   Future<bool> updateCarStatus(String carId, int status) async {
//     try {
//       final db = await database;
//       await db.update(
//         _carsTable,
//         {
//           'status': status,
//           'updated_at': DateTime.now().toIso8601String(),
//         },
//         where: 'car_id = ?',
//         whereArgs: [carId],
//       );
//       return true;
//     } catch (e) {
//       print('Error updating car status: $e');
//       return false;
//     }
//   }

//   @override
//   Future<bool> deleteCar(String carId) async {
//     try {
//       final db = await database;
//       await db.delete(
//         _carsTable,
//         where: 'car_id = ?',
//         whereArgs: [carId],
//       );
//       return true;
//     } catch (e) {
//       print('Error deleting car: $e');
//       return false;
//     }
//   }

//   @override
//   Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
//     try {
//       // For SQLite, we'll store images in the app's documents directory
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/car-images/$fileName');
      
//       // Create directory if it doesn't exist
//       await file.parent.create(recursive: true);
      
//       // Write image bytes to file
//       await file.writeAsBytes(imageBytes);
      
//       // Return the local file path
//       return file.path;
//     } catch (e) {
//       print('Error uploading image: $e');
//       return null;
//     }
//   }

//   @override
//   Future<String?> uploadImageFromUrl(String imageUrl) async {
//     // For scraped images, we just return the original URL
//     return imageUrl;
//   }

//   @override
//   Future<bool> deleteImage(String fileName) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/car-images/$fileName');
      
//       if (await file.exists()) {
//         await file.delete();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print('Error deleting image: $e');
//       return false;
//     }
//   }

//   // AdminDataSource implementation
//   @override
//   Future<bool> authenticateAdmin(String username, String password) async {
//     try {
//       print('SqliteCarDataSource: Authenticating admin with username: $username');

//       final db = await database;
//       final List<Map<String, dynamic>> result = await db.query(
//         _adminsTable,
//         where: 'username = ? AND password = ?',
//         whereArgs: [username, password],
//       );

//       if (result.isNotEmpty) {
//         print('SqliteCarDataSource: Admin authentication successful');
//         return true;
//       }
//       print('SqliteCarDataSource: No admin user found with these credentials');
//       return false;
//     } catch (e) {
//       print('SqliteCarDataSource: Error authenticating admin: $e');
//       return false;
//     }
//   }

//   @override
//   Future<int> getAdminCount() async {
//     try {
//       final db = await database;
//       final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_adminsTable');
//       return result.first['count'] as int;
//     } catch (e) {
//       print('SqliteCarDataSource: Error getting admin count: $e');
//       return 0;
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getRecentAdmins({int limit = 5}) async {
//     try {
//       final db = await database;
//       final List<Map<String, dynamic>> result = await db.query(
//         _adminsTable,
//         orderBy: 'created_at DESC',
//         limit: limit,
//       );
//       return result;
//     } catch (e) {
//       print('SqliteCarDataSource: Error getting recent admins: $e');
//       return [];
//     }
//   }

//   // UserDataSource implementation
//   @override
//   Future<int> getUserCount() async {
//     try {
//       final db = await database;
//       final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_usersTable');
//       return result.first['count'] as int;
//     } catch (e) {
//       print('SqliteCarDataSource: Error getting user count: $e');
//       return 0;
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getAllUsers() async {
//     try {
//       final db = await database;
//       final List<Map<String, dynamic>> result = await db.query(_usersTable);
//       return result;
//     } catch (e) {
//       print('SqliteCarDataSource: Error getting all users: $e');
//       return [];
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 5}) async {
//     try {
//       final db = await database;
//       final List<Map<String, dynamic>> result = await db.query(
//         _usersTable,
//         orderBy: 'created_at DESC',
//         limit: limit,
//       );
//       return result;
//     } catch (e) {
//       print('SqliteCarDataSource: Error getting recent users: $e');
//       return [];
//     }
//   }

//   @override
//   Future<bool> deleteUser(String userId) async {
//     try {
//       final db = await database;
//       await db.delete(
//         _usersTable,
//         where: 'user_id = ?',
//         whereArgs: [userId],
//       );
//       return true;
//     } catch (e) {
//       print('SqliteCarDataSource: Error deleting user: $e');
//       return false;
//     }
//   }

//   // DashboardDataSource implementation
//   @override
//   Future<Map<String, dynamic>> getDashboardStats() async {
//     try {
//       final db = await database;
      
//       final carsResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_carsTable');
//       final usersResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_usersTable');
//       final adminsResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_adminsTable');
      
//       final totalCars = carsResult.first['count'] as int;
//       final totalUsers = usersResult.first['count'] as int;
//       final totalAdmins = adminsResult.first['count'] as int;

//       final availableCarsResult = await db.rawQuery(
//         'SELECT COUNT(*) as count FROM $_carsTable WHERE status = 1'
//       );
//       final unavailableCarsResult = await db.rawQuery(
//         'SELECT COUNT(*) as count FROM $_carsTable WHERE status = 2'
//       );
//       final avgPriceResult = await db.rawQuery(
//         'SELECT AVG(price) as avg FROM $_carsTable'
//       );

//       final availableCars = availableCarsResult.first['count'] as int;
//       final unavailableCars = unavailableCarsResult.first['count'] as int;
//       final avgPrice = (avgPriceResult.first['avg'] as double?) ?? 0.0;

//       return {
//         'totalCars': totalCars,
//         'totalUsers': totalUsers,
//         'totalAdmins': totalAdmins,
//         'availableCars': availableCars,
//         'unavailableCars': unavailableCars,
//         'avgPrice': avgPrice,
//       };
//     } catch (e) {
//       print('SqliteCarDataSource: Error getting dashboard stats: $e');
//       return {
//         'totalCars': 0,
//         'totalUsers': 0,
//         'totalAdmins': 0,
//         'availableCars': 0,
//         'unavailableCars': 0,
//         'avgPrice': 0,
//       };
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getRecentCars({int limit = 5}) async {
//     try {
//       final db = await database;
//       final List<Map<String, dynamic>> result = await db.query(
//         _carsTable,
//         orderBy: 'created_at DESC',
//         limit: limit,
//       );
//       return result.map((map) => _convertSqliteToJson(map)).toList();
//     } catch (e) {
//       print('SqliteCarDataSource: Error getting recent cars: $e');
//       return [];
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getRecentPosts({int limit = 5}) async {
//     try {
//       final db = await database;
//       final List<Map<String, dynamic>> result = await db.query(
//         _postsTable,
//         orderBy: 'created_at DESC',
//         limit: limit,
//       );
//       return result;
//     } catch (e) {
//       print('SqliteCarDataSource: Error getting recent posts: $e');
//       return [];
//     }
//   }

//   // Helper method to convert SQLite column names to JSON format
//   Map<String, dynamic> _convertSqliteToJson(Map<String, dynamic> map) {
//     final converted = Map<String, dynamic>.from(map);
    
//     // Convert SQLite column names to JSON format
//     converted['car_id'] = converted.remove('car_id');
//     converted['fuel_type'] = converted.remove('fuel_type');
//     converted['engine'] = converted.remove('engine');
//     converted['drive_type'] = converted.remove('drive_type');
//     converted['exterior_color'] = converted.remove('exterior_color');
//     converted['interior_color'] = converted.remove('interior_color');
//     converted['main_image'] = converted.remove('main_image');
//     converted['other_images'] = converted.remove('other_images');
//     converted['show_at'] = converted.remove('show_at');
//     converted['un_show_at'] = converted.remove('un_show_at');
//     converted['auction_start_at'] = converted.remove('auction_start_at');
//     converted['auction_end_at'] = converted.remove('auction_end_at');
//     converted['delete_at'] = converted.remove('delete_at');
//     converted['created_at'] = converted.remove('created_at');
//     converted['updated_at'] = converted.remove('updated_at');

//     // Convert other_images string back to list
//     if (converted['other_images'] != null && converted['other_images'].isNotEmpty) {
//       converted['other_images'] = converted['other_images'].split(',');
//     }

//     return converted;
//   }
// }
