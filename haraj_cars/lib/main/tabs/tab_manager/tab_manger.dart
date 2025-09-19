import 'package:flutter/material.dart';
import 'package:haraj/widgets/side_menu.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/car.dart';
import '../../../../tools/theme_controller.dart';
import '../../../../tools/Palette/theme.dart' as custom_theme;
import '../../../../supabase/supabase_service.dart';
import '../../../tools/dialogs/dialogs.dart';
import 'tab_manger_widgets.dart';
import '../cars_cards_tab/creat_or_update_car/create_update_car_logic.dart';
import '../../../scrapping_tools/car_scraper.dart';
import '../cars_cards_tab/ui/car_details/car_details_screen.dart';
import '../cars_cards_tab/cars_main_search_page.dart';
import '../favorits_tab/favorites_tab.dart';
import '../extra_options/global_sites_tab.dart';
import '../extra_options/info_tab.dart';
import '../../../users/admin_side/admin_worker_dashboard/account_tab.dart';
import '../community_tab/community_tab.dart';
import '../../../users/admin_side/admin_worker_dashboard/dashboard_tab.dart';
import '../../../users/admin_side/admin_worker_dashboard/admin_dashboard_layout.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_role.dart';
import '../../../users/client/client_dashboard.dart';

class TabMangerScreen extends StatefulWidget {
  const TabMangerScreen({Key? key}) : super(key: key);

  @override
  State<TabMangerScreen> createState() => _TabMangerScreenState();
}

class _TabMangerScreenState extends State<TabMangerScreen>
    with TickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();

  int _currentIndex = 0;
  bool _isAdmin = false;

  // Settings menu state
  bool? themeMode; // null = system, true = dark, false = light
  String selectedLanguageA = 'English';
  bool _isLanguageMenuExpanded = false;
  bool _isThemeMenuExpanded = false;
  bool _isMeasurementMenuExpanded = false;
  bool _isCurrencyMenuExpanded = false;
  bool useMetricUnits = true; // true = km, false = miles
  bool useSARCurrency = true; // true = SAR, false = USD
  bool notificationsEnabled = true; // true = enabled, false = disabled

  // Animation controllers
  late AnimationController _languageArrowController;
  late AnimationController _menuAnimationController;
  late AnimationController _themeArrowController;
  late AnimationController _themeMenuController;
  late AnimationController _measurementArrowController;
  late AnimationController _measurementMenuController;
  late AnimationController _currencyArrowController;
  late AnimationController _currencyMenuController;

  late Animation<double> _languageArrowAnimation;
  late Animation<double> _menuAnimation;
  late Animation<double> _themeArrowAnimation;
  late Animation<double> _themeMenuAnimation;
  late Animation<double> _measurementArrowAnimation;
  late Animation<double> _measurementMenuAnimation;
  late Animation<double> _currencyArrowAnimation;
  late Animation<double> _currencyMenuAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize authentication
    _initializeAuth();

    // Initialize animation controllers
    _languageArrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _themeArrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _themeMenuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _measurementArrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _measurementMenuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _currencyArrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _currencyMenuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _languageArrowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _languageArrowController,
      curve: Curves.easeInOut,
    ));

    _menuAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeInOut,
    ));

    _themeArrowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _themeArrowController,
      curve: Curves.easeInOut,
    ));

    _themeMenuAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _themeMenuController,
      curve: Curves.easeInOut,
    ));

    _measurementArrowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _measurementArrowController,
      curve: Curves.easeInOut,
    ));

    _measurementMenuAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _measurementMenuController,
      curve: Curves.easeInOut,
    ));

    _currencyArrowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _currencyArrowController,
      curve: Curves.easeInOut,
    ));

    _currencyMenuAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _currencyMenuController,
      curve: Curves.easeInOut,
    ));

    // Load saved settings
    _loadSettings();
  }

  Future<void> _initializeAuth() async {
    await _authService.initializeAuth();
    setState(() {
      _isAdmin = _authService.isAdmin;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _languageArrowController.dispose();
    _menuAnimationController.dispose();
    _themeArrowController.dispose();
    _themeMenuController.dispose();
    _measurementArrowController.dispose();
    _measurementMenuController.dispose();
    _currencyArrowController.dispose();
    _currencyMenuController.dispose();
    super.dispose();
  }

  void _showAdminLogin() {
    showDialog(
      context: context,
      builder: (context) => AdminLoginDialog(
        onLoginResult: (success) {
          setState(() {
            _isAdmin = success;
            if (success) {
              // Navigate to dashboard when admin logs in
              _currentIndex = 0;
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        },
      ),
    );
  }

  void _showAddCarDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCarDialog(),
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
        status: 1, // Default to available
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
        builder: (context) => AddCarScreen(car: car),
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
    final confirmed = await DeleteCarDialog.show(context, car);

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
    return SideMenu(
      currentIndex: _currentIndex,
      isAdmin: _isAdmin,
      onTabTapped: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.secondary,
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
                        // For Guest/Client: Cars tab is first (main browsing page)
                        // For Admin/Worker: Dashboard is first
                        if (_authService.isAdmin)
                          const AdminDashboardLayout()
                        else
                          CarsTab(
                            isAdmin: _isAdmin,
                            onEditCar: _showEditCarDialog,
                            onDeleteCar: _deleteCar,
                            onShowCarDetails: _showCarDetails,
                            onShowStatusUpdate: _showStatusUpdateDialog,
                          ),

                        // For Admin/Worker: Cars tab is second
                        // For Guest/Client: Dashboard is second (if authenticated)
                        if (_authService.isAdmin)
                          CarsTab(
                            isAdmin: _isAdmin,
                            onEditCar: _showEditCarDialog,
                            onDeleteCar: _deleteCar,
                            onShowCarDetails: _showCarDetails,
                            onShowStatusUpdate: _showStatusUpdateDialog,
                          )
                        else if (_authService.isClient)
                          ClientDashboard(
                            onNavigateToTab: (index) {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        // Global Sites tab
                        const GlobalSitesTab(),
                        // Community tab
                        CommunityTab(isAdmin: _isAdmin),
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
                child: TabManagerWidgets.buildBottomNavigationBar(
                  context,
                  currentIndex: _currentIndex,
                  isAdmin: _isAdmin,
                  onTabTapped: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  onAddCar: _showAddCarDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTheme(bool? themeMode) {
    String themeText;
    if (themeMode == null) {
      themeText = 'System';
    } else if (themeMode == true) {
      themeText = 'Dark';
    } else {
      themeText = 'Light';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme changed to: $themeText'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateLanguage(String language) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to: $language'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateMeasurementUnits(bool useMetric) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Measurement units changed to: ${useMetric ? 'Kilometers' : 'Miles'}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateCurrency(bool useSAR) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Currency changed to: ${useSAR ? 'SAR' : 'USD'}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateNotifications(bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications ${enabled ? 'enabled' : 'disabled'}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildTopNavigationBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[700]
            : colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Hamburger menu button
                GestureDetector(
                  onTap: _toggleDrawer,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.menu,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'HARAJ . OHIO',
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Admin login button (hidden)
                GestureDetector(
                  onTap: _showAdminLogin,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 3-dots menu button
                _buildThreeDotsMenu(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeDotsMenu() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: colorScheme.onPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: _buildSettingsPopupMenu(),
        ),
      ),
    );
  }

  Widget _buildSettingsPopupMenu() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: colorScheme.onPrimary.withOpacity(0.9),
      ),
      tooltip: '',
      color: Colors.transparent,
      elevation: 0,
      splashRadius: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(
        minWidth: 270,
        maxWidth: 270,
      ),
      offset: const Offset(0, 5),
      onOpened: () {
        // Don't reset language menu state - let it stay as it was
        // This allows the language submenu to remain expanded if it was expanded before
      },
      itemBuilder: (BuildContext context) => [
        // Settings menu
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey[700]!.withOpacity(0.3)
                      : custom_theme.light.shade100.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Theme Option
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]!.withOpacity(0.3)
                                  : custom_theme.light.shade100
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return _buildThemeOption(setInnerState);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Divider
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 1,
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                    // Language Option
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]!.withOpacity(0.3)
                                  : custom_theme.light.shade100
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return _buildLanguageOption(setInnerState);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Unit of Measurement Option
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]!.withOpacity(0.3)
                                  : custom_theme.light.shade100
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return _buildMeasurementOption(setInnerState);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Currency Option
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.grey[700]!.withOpacity(0.3)
                                  : custom_theme.light.shade100
                                      .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setInnerState) {
                                return _buildCurrencyOption(setInnerState);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Notification Option
                    StatefulBuilder(
                      builder: (context, setInnerState) {
                        return _buildNotificationOption(setInnerState);
                      },
                    ),
                    // Contact Us Option
                    _buildContactOption(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(StateSetter setInnerState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () {
            setInnerState(() {
              _isThemeMenuExpanded = !_isThemeMenuExpanded;
              if (_isThemeMenuExpanded) {
                _themeArrowController.forward();
                _themeMenuController.forward();
              } else {
                _themeArrowController.reverse();
                _themeMenuController.reverse();
              }
            });
          },
          leading: Icon(
            themeMode == null
                ? Icons.settings
                : themeMode == true
                    ? Icons.dark_mode
                    : Icons.light_mode,
            color: Colors.white,
          ),
          title: const Text(
            'Theme',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  themeMode == null
                      ? 'SYS'
                      : themeMode == true
                          ? 'DARK'
                          : 'LIGHT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RotationTransition(
                turns: _themeArrowAnimation,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _themeMenuAnimation,
          child: FadeTransition(
            opacity: _themeMenuAnimation,
            child: Column(
              children: [
                _buildThemeOptionItem(
                  theme: 'System',
                  code: 'SYS',
                  icon: Icons.settings,
                  isSelected: themeMode == null,
                  setInnerState: setInnerState,
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildThemeOptionItem(
                  theme: 'Light',
                  code: 'LIGHT',
                  icon: Icons.light_mode,
                  isSelected: themeMode == false,
                  setInnerState: setInnerState,
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildThemeOptionItem(
                  theme: 'Dark',
                  code: 'DARK',
                  icon: Icons.dark_mode,
                  isSelected: themeMode == true,
                  setInnerState: setInnerState,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(StateSetter setInnerState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () {
            setInnerState(() {
              _isLanguageMenuExpanded = !_isLanguageMenuExpanded;
              if (_isLanguageMenuExpanded) {
                _languageArrowController.forward();
                _menuAnimationController.forward();
              } else {
                _languageArrowController.reverse();
                _menuAnimationController.reverse();
              }
            });
          },
          leading: const Icon(
            Icons.language,
            color: Colors.white,
          ),
          title: const Text(
            'Language',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  selectedLanguageA == 'العربيه' ? 'AR' : 'EN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RotationTransition(
                turns: _languageArrowAnimation,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _menuAnimation,
          child: FadeTransition(
            opacity: _menuAnimation,
            child: Column(
              children: [
                _buildLanguageOptionItem(
                  language: 'English',
                  code: 'EN',
                  isSelected: selectedLanguageA == 'English',
                  setInnerState: setInnerState,
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildLanguageOptionItem(
                  language: 'العربيه',
                  code: 'AR',
                  isSelected: selectedLanguageA == 'العربيه',
                  setInnerState: setInnerState,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionItem({
    required String theme,
    required String code,
    required IconData icon,
    required bool isSelected,
    required StateSetter setInnerState,
  }) {
    return _buildOptionItem(
      title: theme,
      isSelected: isSelected,
      icon: icon,
      onTap: () {
        setInnerState(() {
          if (theme == 'System') {
            themeMode = null;
          } else if (theme == 'Light') {
            themeMode = false;
          } else {
            themeMode = true;
          }
          _saveSettings();
        });
        // Apply app-wide theme via controller
        ThemeController.instance.setThemeBool(themeMode);
        _updateTheme(themeMode);
      },
    );
  }

  Widget _buildLanguageOptionItem({
    required String language,
    required String code,
    required bool isSelected,
    required StateSetter setInnerState,
  }) {
    return _buildOptionItem(
      title: language,
      isSelected: isSelected,
      onTap: () {
        setInnerState(() {
          selectedLanguageA = language;
          _saveSettings();
        });
        _updateLanguage(language);
      },
    );
  }

  Widget _buildMeasurementOption(StateSetter setInnerState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () {
            setInnerState(() {
              _isMeasurementMenuExpanded = !_isMeasurementMenuExpanded;
              if (_isMeasurementMenuExpanded) {
                _measurementArrowController.forward();
                _measurementMenuController.forward();
              } else {
                _measurementArrowController.reverse();
                _measurementMenuController.reverse();
              }
            });
          },
          leading: Icon(
            useMetricUnits ? Icons.straighten : Icons.straighten_outlined,
            color: Colors.white,
          ),
          title: const Text(
            'Unit',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  useMetricUnits ? 'KM' : 'MI',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RotationTransition(
                turns: _measurementArrowAnimation,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _measurementMenuAnimation,
          child: FadeTransition(
            opacity: _measurementMenuAnimation,
            child: Column(
              children: [
                _buildMeasurementOptionItem(
                  unit: 'Kilometers',
                  code: 'KM',
                  icon: Icons.straighten,
                  isSelected: useMetricUnits,
                  setInnerState: setInnerState,
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildMeasurementOptionItem(
                  unit: 'Miles',
                  code: 'MI',
                  icon: Icons.straighten_outlined,
                  isSelected: !useMetricUnits,
                  setInnerState: setInnerState,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementOptionItem({
    required String unit,
    required String code,
    required IconData icon,
    required bool isSelected,
    required StateSetter setInnerState,
  }) {
    return _buildOptionItem(
      title: unit,
      isSelected: isSelected,
      icon: icon,
      onTap: () {
        setInnerState(() {
          useMetricUnits = (unit == 'Kilometers');
          _saveSettings();
        });
        _updateMeasurementUnits(useMetricUnits);
      },
    );
  }

  Widget _buildCurrencyOption(StateSetter setInnerState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () {
            setInnerState(() {
              _isCurrencyMenuExpanded = !_isCurrencyMenuExpanded;
              if (_isCurrencyMenuExpanded) {
                _currencyArrowController.forward();
                _currencyMenuController.forward();
              } else {
                _currencyArrowController.reverse();
                _currencyMenuController.reverse();
              }
            });
          },
          leading: Icon(
            useSARCurrency ? Icons.attach_money : Icons.attach_money_outlined,
            color: Colors.white,
          ),
          title: const Text(
            'Currency',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  useSARCurrency ? 'SAR' : 'USD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RotationTransition(
                turns: _currencyArrowAnimation,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _currencyMenuAnimation,
          child: FadeTransition(
            opacity: _currencyMenuAnimation,
            child: Column(
              children: [
                _buildCurrencyOptionItem(
                  currency: 'Saudi Riyal',
                  code: 'SAR',
                  icon: Icons.attach_money,
                  isSelected: useSARCurrency,
                  setInnerState: setInnerState,
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildCurrencyOptionItem(
                  currency: 'US Dollar',
                  code: 'USD',
                  icon: Icons.attach_money_outlined,
                  isSelected: !useSARCurrency,
                  setInnerState: setInnerState,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyOptionItem({
    required String currency,
    required String code,
    required IconData icon,
    required bool isSelected,
    required StateSetter setInnerState,
  }) {
    return _buildOptionItem(
      title: currency,
      isSelected: isSelected,
      icon: icon,
      onTap: () {
        setInnerState(() {
          useSARCurrency = (currency == 'Saudi Riyal');
          _saveSettings();
        });
        _updateCurrency(useSARCurrency);
      },
    );
  }

  Widget _buildNotificationOption(StateSetter setInnerState) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setInnerState(() {
          notificationsEnabled = !notificationsEnabled;
          _saveSettings();
        });
        _updateNotifications(notificationsEnabled);
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[700]!.withOpacity(0.3)
                    : custom_theme.light.shade100.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  notificationsEnabled
                      ? Icons.notifications
                      : Icons.notifications_off,
                  color: Colors.white,
                ),
                title: Text(
                  notificationsEnabled ? 'Notifications' : 'Notifications',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (bool value) {
                    setInnerState(() {
                      notificationsEnabled = value;
                      _saveSettings();
                    });
                    _updateNotifications(notificationsEnabled);
                  },
                  activeColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  inactiveThumbColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption() {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _showContactDialog,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[700]!.withOpacity(0.3)
                    : custom_theme.light.shade100.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: const ListTile(
                leading: Icon(
                  Icons.contact_support,
                  color: Colors.white,
                ),
                title: Text(
                  'Contact Us',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Save theme mode
    if (themeMode == null) {
      await prefs.remove('theme_mode');
    } else {
      await prefs.setBool('theme_mode', themeMode!);
    }

    // Save language
    await prefs.setString('selected_language', selectedLanguageA);

    // Save measurement units
    await prefs.setBool('use_metric_units', useMetricUnits);

    // Save currency
    await prefs.setBool('use_sar_currency', useSARCurrency);

    // Save notifications
    await prefs.setBool('notifications_enabled', notificationsEnabled);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    if (prefs.containsKey('theme_mode')) {
      themeMode = prefs.getBool('theme_mode');
    } else {
      themeMode = null; // Default to system
    }

    // Load language
    selectedLanguageA = prefs.getString('selected_language') ?? 'English';

    // Load measurement units
    useMetricUnits = prefs.getBool('use_metric_units') ?? true; // Default to km

    // Load currency
    useSARCurrency =
        prefs.getBool('use_sar_currency') ?? true; // Default to SAR

    // Load notifications
    notificationsEnabled =
        prefs.getBool('notifications_enabled') ?? true; // Default to enabled

    // Update UI if widget is mounted
    if (mounted) {
      setState(() {});
    }
  }

  void _showContactDialog() {
    ContactDialog.show(context);
  }

  void _toggleDrawer() {
    SideMenu.toggle(context);
  }
}
