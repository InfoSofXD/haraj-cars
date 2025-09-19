import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import '../../core/models/user_role.dart';
import '../../core/models/app_user.dart';
import '../../core/services/auth_service.dart';
import '../../tools/Palette/theme.dart' as custom_theme;
import '../../supabase/supabase_service.dart';
import '../../main/tabs/cars_cards_tab/ui/car_details/car_details_screen.dart';
import '../../models/car.dart';

class ClientDashboard extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const ClientDashboard({
    Key? key,
    required this.onNavigateToTab,
  }) : super(key: key);

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  List<Car> _favoriteCars = [];
  List<Car> _recentlyViewedCars = [];
  Map<String, dynamic> _userStats = {};

  AppUser? get currentUser => _authService.currentUser;

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  Future<void> _loadClientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadFavoriteCars();
      await _loadRecentlyViewedCars();
      await _loadUserStats();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFavoriteCars() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = currentUser?.id;
      
      if (userId == null) return;

      final response = await supabase
          .from('user_favorites')
          .select('car_id')
          .eq('user_id', userId);

      if (response.isNotEmpty) {
        final carIds = response.map((fav) => fav['car_id'] as String).toList();
         final carsResponse = await supabase
             .from('cars')
             .select('*')
             .inFilter('car_id', carIds);

        final cars = carsResponse.map((carData) => Car.fromJson(carData)).toList();
        setState(() {
          _favoriteCars = cars;
        });
      }
    } catch (e) {
      print('Error loading favorite cars: $e');
      setState(() {
        _favoriteCars = [];
      });
    }
  }

  Future<void> _loadRecentlyViewedCars() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('cars')
          .select('*')
          .order('created_at', ascending: false)
          .limit(5);

      final cars = response.map((carData) => Car.fromJson(carData)).toList();
      setState(() {
        _recentlyViewedCars = cars;
      });
    } catch (e) {
      print('Error loading recently viewed cars: $e');
      setState(() {
        _recentlyViewedCars = [];
      });
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = currentUser?.id;
      
      if (userId == null) return;

      // Get favorite count
      final favoritesResponse = await supabase
          .from('user_favorites')
          .select('id')
          .eq('user_id', userId);
      
      final favoriteCount = favoritesResponse.length;

      // Get account creation date
      final accountCreatedAt = currentUser?.createdAt ?? DateTime.now();
      final daysSinceJoined = DateTime.now().difference(accountCreatedAt).inDays;

      setState(() {
        _userStats = {
          'favoriteCount': favoriteCount,
          'daysSinceJoined': daysSinceJoined,
          'accountCreatedAt': accountCreatedAt,
        };
      });
    } catch (e) {
      print('Error loading user stats: $e');
      setState(() {
        _userStats = {
          'favoriteCount': 0,
          'daysSinceJoined': 0,
          'accountCreatedAt': DateTime.now(),
        };
      });
    }
  }

  Future<void> _removeFavorite(Car car) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = currentUser?.id;
      
      if (userId == null) return;

      await supabase
          .from('user_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('car_id', car.carId);

      // Refresh favorites
      await _loadFavoriteCars();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCarDetails(Car car) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarDetailsScreen(car: car),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: theme.brightness == Brightness.dark
          ? colorScheme.background
          : Colors.white,
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Content (full screen, content scrolls under floating title)
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),

          // Floating Title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingTitle(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 100, // Space for floating title
        bottom: 110, // Space for floating bottom nav bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Welcome Section
          _buildWelcomeSection(),

          const SizedBox(height: 24),

          // Stats Section
          _buildStatsSection(),

          const SizedBox(height: 24),

          // Favorites Section
          _buildFavoritesSection(),

          const SizedBox(height: 24),

          // Recently Viewed Section
          _buildRecentlyViewedSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : custom_theme.light.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    Text(
                      currentUser?.fullName ?? currentUser?.email ?? 'User',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[700],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Client',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : custom_theme.light.shade800,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Favorites',
                _userStats['favoriteCount']?.toString() ?? '0',
                Icons.favorite,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Days as Member',
                _userStats['daysSinceJoined']?.toString() ?? '0',
                Icons.calendar_today,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : custom_theme.light.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.onSurface,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.grey[700],
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Favorites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade800,
                fontFamily: 'Tajawal',
              ),
            ),
            if (_favoriteCars.isNotEmpty)
              TextButton(
                onPressed: () {
                  widget.onNavigateToTab(1); // Navigate to favorites tab
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_favoriteCars.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surface
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.2)
                    : custom_theme.light.shade300,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start browsing cars and add them to your favorites!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onNavigateToTab(0); // Navigate to cars tab
                  },
                  child: const Text('Browse Cars'),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _favoriteCars.length,
              itemBuilder: (context, index) {
                final car = _favoriteCars[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildCarCard(car, isFavorite: true),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecentlyViewedSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recently Added Cars',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade800,
                fontFamily: 'Tajawal',
              ),
            ),
            TextButton(
              onPressed: () {
                widget.onNavigateToTab(0); // Navigate to cars tab
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentlyViewedCars.length,
            itemBuilder: (context, index) {
              final car = _recentlyViewedCars[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: _buildCarCard(car),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarCard(Car car, {bool isFavorite = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _showCarDetails(car),
      child: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? colorScheme.surface
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.2)
                : custom_theme.light.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.grey[200],
                ),
                child: car.mainImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          car.mainImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.directions_car,
                              size: 48,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.directions_car,
                        size: 48,
                        color: Colors.grey,
                      ),
              ),
            ),
            // Car Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.brand} ${car.model}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontFamily: 'Tajawal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.year} • ${car.mileage.toString()} miles',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[600],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${car.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        if (isFavorite)
                          GestureDetector(
                            onTap: () => _removeFavorite(car),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingTitle() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[700]!.withOpacity(0.3)
                  : custom_theme.light.shade100.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Client Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : colorScheme.onSurface,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadClientData,
                  icon: Icon(
                    Icons.refresh,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
