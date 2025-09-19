// // firebase_car_data_source.dart - Firebase implementation of car data source

// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../models/car.dart';
// import 'car_data_source.dart';

// /// Firebase implementation of car data source
// class FirebaseCarDataSource implements CarDataSource, AdminDataSource, UserDataSource, DashboardDataSource {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Future<List<Car>> getCars() async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('cars')
//           .orderBy('createdAt', descending: true)
//           .get();

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return Car.fromJson(data);
//       }).toList();
//     } catch (e) {
//       print('Error fetching cars: $e');
//       return [];
//     }
//   }

//   @override
//   Future<List<Car>> searchCars(String query) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('cars')
//           .where('description', isGreaterThanOrEqualTo: query)
//           .where('description', isLessThan: query + '\uf8ff')
//           .orderBy('createdAt', descending: true)
//           .get();

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return Car.fromJson(data);
//       }).toList();
//     } catch (e) {
//       print('Error searching cars: $e');
//       return [];
//     }
//   }

//   @override
//   Future<List<Car>> filterCarsByPrice(double minPrice, double maxPrice) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('cars')
//           .where('price', isGreaterThanOrEqualTo: minPrice)
//           .where('price', isLessThanOrEqualTo: maxPrice)
//           .orderBy('createdAt', descending: true)
//           .get();

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return Car.fromJson(data);
//       }).toList();
//     } catch (e) {
//       print('Error filtering cars by price: $e');
//       return [];
//     }
//   }

//   @override
//   Future<bool> addCar(Car car) async {
//     try {
//       print('FirebaseCarDataSource: Adding car with data: ${car.toJson()}');

//       final carData = car.toJson();
//       carData.remove('id');
//       carData.remove('car_id');
//       carData.remove('created_at');
//       carData.remove('updated_at');

//       // Convert DateTime objects to Timestamp for Firestore
//       if (carData['show_at'] != null) {
//         carData['showAt'] = Timestamp.fromDate(DateTime.parse(carData['show_at']));
//         carData.remove('show_at');
//       }
//       if (carData['un_show_at'] != null) {
//         carData['unShowAt'] = Timestamp.fromDate(DateTime.parse(carData['un_show_at']));
//         carData.remove('un_show_at');
//       }
//       if (carData['auction_start_at'] != null) {
//         carData['auctionStartAt'] = Timestamp.fromDate(DateTime.parse(carData['auction_start_at']));
//         carData.remove('auction_start_at');
//       }
//       if (carData['auction_end_at'] != null) {
//         carData['auctionEndAt'] = Timestamp.fromDate(DateTime.parse(carData['auction_end_at']));
//         carData.remove('auction_end_at');
//       }
//       if (carData['delete_at'] != null) {
//         carData['deleteAt'] = Timestamp.fromDate(DateTime.parse(carData['delete_at']));
//         carData.remove('delete_at');
//       }

//       carData['createdAt'] = Timestamp.fromDate(DateTime.now());
//       carData['updatedAt'] = Timestamp.fromDate(DateTime.now());

//       await _firestore.collection('cars').add(carData);
//       print('FirebaseCarDataSource: Car added successfully');
//       return true;
//     } catch (e) {
//       print('FirebaseCarDataSource: Error adding car: $e');
//       return false;
//     }
//   }

//   @override
//   Future<bool> updateCar(Car car) async {
//     try {
//       print('FirebaseCarDataSource: Updating car with data: ${car.toJson()}');

//       final carData = car.toJson();
//       carData.remove('id');
//       carData.remove('car_id');
//       carData.remove('created_at');

//       // Convert DateTime objects to Timestamp for Firestore
//       if (carData['show_at'] != null) {
//         carData['showAt'] = Timestamp.fromDate(DateTime.parse(carData['show_at']));
//         carData.remove('show_at');
//       }
//       if (carData['un_show_at'] != null) {
//         carData['unShowAt'] = Timestamp.fromDate(DateTime.parse(carData['un_show_at']));
//         carData.remove('un_show_at');
//       }
//       if (carData['auction_start_at'] != null) {
//         carData['auctionStartAt'] = Timestamp.fromDate(DateTime.parse(carData['auction_start_at']));
//         carData.remove('auction_start_at');
//       }
//       if (carData['auction_end_at'] != null) {
//         carData['auctionEndAt'] = Timestamp.fromDate(DateTime.parse(carData['auction_end_at']));
//         carData.remove('auction_end_at');
//       }
//       if (carData['delete_at'] != null) {
//         carData['deleteAt'] = Timestamp.fromDate(DateTime.parse(carData['delete_at']));
//         carData.remove('delete_at');
//       }

//       carData['updatedAt'] = Timestamp.fromDate(DateTime.now());

//       await _firestore.collection('cars').doc(car.carId).update(carData);
//       print('FirebaseCarDataSource: Car updated successfully');
//       return true;
//     } catch (e) {
//       print('FirebaseCarDataSource: Error updating car: $e');
//       return false;
//     }
//   }

//   @override
//   Future<bool> updateCarStatus(String carId, int status) async {
//     try {
//       await _firestore.collection('cars').doc(carId).update({
//         'status': status,
//         'updatedAt': Timestamp.fromDate(DateTime.now()),
//       });
//       return true;
//     } catch (e) {
//       print('Error updating car status: $e');
//       return false;
//     }
//   }

//   @override
//   Future<bool> deleteCar(String carId) async {
//     try {
//       await _firestore.collection('cars').doc(carId).delete();
//       return true;
//     } catch (e) {
//       print('Error deleting car: $e');
//       return false;
//     }
//   }

//   @override
//   Future<String?> uploadImage(Uint8List imageBytes, String fileName) async {
//     try {
//       final ref = _storage.ref().child('car-images/$fileName');
//       final uploadTask = ref.putData(imageBytes);
//       final snapshot = await uploadTask;
//       final downloadUrl = await snapshot.ref.getDownloadURL();
//       return downloadUrl;
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
//       final ref = _storage.ref().child('car-images/$fileName');
//       await ref.delete();
//       return true;
//     } catch (e) {
//       print('Error deleting image: $e');
//       return false;
//     }
//   }

//   // AdminDataSource implementation
//   @override
//   Future<bool> authenticateAdmin(String username, String password) async {
//     try {
//       print('FirebaseCarDataSource: Authenticating admin with username: $username');

//       // For Firebase, we'll use custom claims or a separate admin collection
//       // This is a simplified implementation - in production, use proper authentication
//       final querySnapshot = await _firestore
//           .collection('admins')
//           .where('username', isEqualTo: username)
//           .where('password', isEqualTo: password)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         print('FirebaseCarDataSource: Admin authentication successful');
//         return true;
//       }
//       print('FirebaseCarDataSource: No admin user found with these credentials');
//       return false;
//     } catch (e) {
//       print('FirebaseCarDataSource: Error authenticating admin: $e');
//       return false;
//     }
//   }

//   @override
//   Future<int> getAdminCount() async {
//     try {
//       final querySnapshot = await _firestore.collection('admins').get();
//       return querySnapshot.docs.length;
//     } catch (e) {
//       print('FirebaseCarDataSource: Error getting admin count: $e');
//       return 0;
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getRecentAdmins({int limit = 5}) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('admins')
//           .orderBy('createdAt', descending: true)
//           .limit(limit)
//           .get();

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();
//     } catch (e) {
//       print('FirebaseCarDataSource: Error getting recent admins: $e');
//       return [];
//     }
//   }

//   // UserDataSource implementation
//   @override
//   Future<int> getUserCount() async {
//     try {
//       final querySnapshot = await _firestore.collection('users').get();
//       return querySnapshot.docs.length;
//     } catch (e) {
//       print('FirebaseCarDataSource: Error getting user count: $e');
//       return 0;
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getAllUsers() async {
//     try {
//       final querySnapshot = await _firestore.collection('users').get();
//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();
//     } catch (e) {
//       print('FirebaseCarDataSource: Error getting all users: $e');
//       return [];
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 5}) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('users')
//           .orderBy('createdAt', descending: true)
//           .limit(limit)
//           .get();

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();
//     } catch (e) {
//       print('FirebaseCarDataSource: Error getting recent users: $e');
//       return [];
//     }
//   }

//   @override
//   Future<bool> deleteUser(String userId) async {
//     try {
//       await _firestore.collection('users').doc(userId).delete();
//       return true;
//     } catch (e) {
//       print('FirebaseCarDataSource: Error deleting user: $e');
//       return false;
//     }
//   }

//   // DashboardDataSource implementation
//   @override
//   Future<Map<String, dynamic>> getDashboardStats() async {
//     try {
//       final carsSnapshot = await _firestore.collection('cars').get();
//       final usersSnapshot = await _firestore.collection('users').get();
//       final adminsSnapshot = await _firestore.collection('admins').get();

//       final totalCars = carsSnapshot.docs.length;
//       final totalUsers = usersSnapshot.docs.length;
//       final totalAdmins = adminsSnapshot.docs.length;

//       int availableCars = 0;
//       int unavailableCars = 0;
//       double totalPrice = 0;

//       for (final doc in carsSnapshot.docs) {
//         final data = doc.data();
//         final status = data['status'] ?? 1;
//         final price = (data['price'] ?? 0).toDouble();
        
//         if (status == 1) {
//           availableCars++;
//         } else if (status == 2) {
//           unavailableCars++;
//         }
        
//         totalPrice += price;
//       }

//       final avgPrice = totalCars > 0 ? totalPrice / totalCars : 0;

//       return {
//         'totalCars': totalCars,
//         'totalUsers': totalUsers,
//         'totalAdmins': totalAdmins,
//         'availableCars': availableCars,
//         'unavailableCars': unavailableCars,
//         'avgPrice': avgPrice,
//       };
//     } catch (e) {
//       print('FirebaseCarDataSource: Error getting dashboard stats: $e');
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
//       final querySnapshot = await _firestore
//           .collection('cars')
//           .orderBy('createdAt', descending: true)
//           .limit(limit)
//           .get();

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();
//     } catch (e) {
//       print('FirebaseCarDataSource: Error getting recent cars: $e');
//       return [];
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getRecentPosts({int limit = 5}) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('posts')
//           .orderBy('createdAt', descending: true)
//           .limit(limit)
//           .get();

//       return querySnapshot.docs.map((doc) {
//         final data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();
//     } catch (e) {
//       print('FirebaseCarDataSource: Error getting recent posts: $e');
//       return [];
//     }
//   }
// }
