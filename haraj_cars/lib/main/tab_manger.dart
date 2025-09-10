import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/car.dart';
import '../../supabase/supabase_service.dart';
import '../widgets/admin_login_dialog.dart';
import '../widgets/status_update_dialog.dart';
import '../screens/add_car_screen.dart';
import '../screens/edit_car_screen.dart';
import '../screens/car_scraper.dart';
import '../widgets/car_details_screen.dart';
import 'tabs/cars_tab.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/global_sites_tab.dart';
import 'tabs/info_tab.dart';
import 'tabs/account_tab.dart';

class TabMangerScreen extends StatefulWidget {
  const TabMangerScreen({Key? key}) : super(key: key);

  @override
  State<TabMangerScreen> createState() => _TabMangerScreenState();
}

class _TabMangerScreenState extends State<TabMangerScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final PageController _pageController = PageController();

  int _currentIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAdminLogin() {
    showDialog(
      context: context,
      builder: (context) => AdminLoginDialog(
        onLoginResult: (success) {
          setState(() {
            _isAdmin = success;
          });
        },
      ),
    );
  }

  void _showAddCarDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Car'),
        content: const Text('How would you like to add a new car?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showManualAddCar();
            },
            child: const Text('Add Manually'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showScrapeCarDialog();
            },
            child: const Text('Scrape Car Data'),
          ),
        ],
      ),
    );
  }

  void _showManualAddCar() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const AddCarScreen(),
      ),
    )
        .then((result) {
      if (result == true) {
        // Car added successfully - cars tab will handle refreshing
      }
    });
  }

  void _showScrapeCarDialog() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const CarScraper(),
      ),
    )
        .then((result) {
      if (result != null && result is Map<String, dynamic>) {
        _addScrapedCar(result);
      }
    });
  }

  Future<void> _addScrapedCar(Map<String, dynamic> scrapedData) async {
    try {
      // Extract data from scraped result
      final title = scrapedData['Title']?.toString() ?? '';
      final priceStr = scrapedData['Price']?.toString() ?? '';
      final brand = scrapedData['Brand']?.toString() ?? '';
      final model = scrapedData['Model']?.toString() ?? '';
      final yearStr = scrapedData['Year']?.toString() ?? '';
      final mileageStr = scrapedData['Mileage']?.toString() ?? '';
      final transmission =
          scrapedData['Transmission']?.toString() ?? 'Automatic';
      final fuelType = scrapedData['Fuel Type']?.toString() ?? 'Petrol';
      final engine = scrapedData['Engine']?.toString() ?? '';
      final exteriorColor = scrapedData['Exterior Color']?.toString() ?? '';
      final interiorColor = scrapedData['Interior Color']?.toString() ?? '';
      final drivetrain = scrapedData['Drivetrain']?.toString() ?? 'FWD';
      final dealer = scrapedData['Dealer']?.toString() ?? '';

      // Parse price (remove currency symbols and commas)
      final cleanPrice = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.tryParse(cleanPrice) ?? 0.0;

      // Parse year
      final year = int.tryParse(yearStr) ?? DateTime.now().year;

      // Parse mileage (remove "miles" text and commas)
      final cleanMileage = mileageStr.replaceAll(RegExp(r'[^\d]'), '');
      final mileage = int.tryParse(cleanMileage) ?? 0;

      // Convert drivetrain to our format
      String driveType = 'FWD';
      if (drivetrain.toLowerCase().contains('all-wheel') ||
          drivetrain.toLowerCase().contains('awd')) {
        driveType = 'AWD';
      } else if (drivetrain.toLowerCase().contains('rear-wheel') ||
          drivetrain.toLowerCase().contains('rwd')) {
        driveType = 'RWD';
      }

      // Convert transmission to our format
      String transmissionType = 'Automatic';
      if (transmission.toLowerCase().contains('manual')) {
        transmissionType = 'Manual';
      }

      // Convert fuel type to our format
      String fuelTypeConverted = 'Petrol';
      if (fuelType.toLowerCase().contains('diesel')) {
        fuelTypeConverted = 'Diesel';
      } else if (fuelType.toLowerCase().contains('electric')) {
        fuelTypeConverted = 'Electric';
      } else if (fuelType.toLowerCase().contains('hybrid')) {
        fuelTypeConverted = 'Hybrid';
      }

      // Create car object
      final car = Car(
        carId: DateTime.now().millisecondsSinceEpoch.toString(),
        description: title.isNotEmpty ? title : 'Scraped car data',
        price: price,
        brand: brand.isNotEmpty ? brand : 'Unknown',
        model: model.isNotEmpty ? model : 'Unknown',
        year: year,
        mileage: mileage,
        transmission: transmissionType,
        fuelType: fuelTypeConverted,
        engineSize: engine.isNotEmpty ? engine : 'Unknown',
        horsepower: 0, // Not available from scraping
        driveType: driveType,
        exteriorColor: exteriorColor.isNotEmpty ? exteriorColor : 'Unknown',
        interiorColor: interiorColor.isNotEmpty ? interiorColor : 'Unknown',
        doors: 4, // Default value
        seats: 5, // Default value
        mainImage: null, // Will be handled separately for images
        otherImages: null,
        contact: dealer.isNotEmpty ? dealer : 'Contact seller',
        status: true, // Default to available
        condition: false, // Default to used
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add car to database
      final success = await _supabaseService.addCar(car);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Car added successfully from scraped data!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add scraped car. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding scraped car: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditCarDialog(Car car) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => EditCarScreen(car: car),
      ),
    )
        .then((result) {
      if (result == true) {
        // Car edited successfully - cars tab will handle refreshing
      }
    });
  }

  void _showCarDetails(Car car) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarDetailsScreen(car: car),
      ),
    );
  }

  void _showStatusUpdateDialog(Car car) {
    showDialog(
      context: context,
      builder: (context) => StatusUpdateDialog(
        car: car,
        onStatusUpdated: (success) {
          if (success) {
            // Status updated - cars tab will handle refreshing
          }
        },
      ),
    );
  }

  Future<void> _deleteCar(Car car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Car'),
        content:
            Text('Are you sure you want to delete "${car.computedTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _supabaseService.deleteCar(car.carId);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Car deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting car: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0),
              Color(0xFF1976D2),
              Color(0xFF1E88E5),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content (full screen)
              Column(
                children: [
                  // Top Navigation Bar
                  _buildTopNavigationBar(),

                  // Main Content (full screen, content scrolls under floating elements)
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      children: [
                        // Cars tab
                        CarsTab(
                          isAdmin: _isAdmin,
                          onEditCar: _showEditCarDialog,
                          onDeleteCar: _deleteCar,
                          onShowCarDetails: _showCarDetails,
                          onShowStatusUpdate: _showStatusUpdateDialog,
                        ),
                        // Global Sites tab
                        const GlobalSitesTab(),
                        // Favorites tab
                        const FavoritesTab(),
                        // Info tab
                        const InfoTab(),
                        // Account tab
                        const AccountTab(),
                      ],
                    ),
                  ),
                ],
              ),

              // Floating Bottom Navigation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNavigationBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HARAJ . USA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                letterSpacing: 1.2,
              ),
            ),
            Row(
              children: [
                _buildTopNavItem('BRANDS'),
                const SizedBox(width: 16),
                _buildTopNavItem('CONTACT US'),
                const SizedBox(width: 16),
                _buildTopNavItem('ENG ▼'),
                const SizedBox(width: 16),
                // Admin login button (hidden)
                GestureDetector(
                  onTap: _showAdminLogin,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavItem(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(64),
        topRight: Radius.circular(64),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2196F3).withOpacity(0.3),
                const Color(0xFF1976D2).withOpacity(0.4),
                const Color(0xFF1565C0).withOpacity(0.3),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(64),
              topRight: Radius.circular(64),
            ),
            border: Border.all(
              color: const Color(0xFF42A5F5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.4),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Main navigation tabs
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomNavItem(
                          Icons.directions_car, 0, _currentIndex == 0),
                      _buildBottomNavItem(Icons.public, 1, _currentIndex == 1),
                      _buildBottomNavItem(
                          Icons.favorite, 2, _currentIndex == 2),
                      _buildBottomNavItem(Icons.info, 3, _currentIndex == 3),
                      _buildBottomNavItem(Icons.person, 4, _currentIndex == 4),
                    ],
                  ),
                ),
                // Admin add button (only show in cars tab when admin)
                if (_isAdmin && _currentIndex == 0) ...[
                  const SizedBox(width: 16),
                  _buildAdminAddButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index, bool isActive) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAdminAddButton() {
    return GestureDetector(
      onTap: _showAddCarDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.8),
              const Color(0xFF2E7D32).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF81C784),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
