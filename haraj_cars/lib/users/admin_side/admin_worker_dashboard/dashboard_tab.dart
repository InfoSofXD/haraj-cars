import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../tools/Palette/theme.dart' as custom_theme;
import '../../../../supabase/supabase_service.dart';
import '../../../../tools/dialogs/add_car_dialog.dart';
import '../../../../tools/bottom_sheets/users_bottom_sheet.dart';

class DashboardTab extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const DashboardTab({
    Key? key,
    required this.onNavigateToTab,
  }) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _recentCars = [];
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _recentPosts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load statistics
      await _loadStatistics();

      // Load recent data
      await _loadRecentCars();
      await _loadRecentUsers();
      await _loadRecentPosts();

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
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final supabase = Supabase.instance.client;

      // Get total cars count
      final carsResponse = await supabase.from('cars').select('*');
      final totalCars = carsResponse.length;

      // Get cars by status - handle both boolean and integer status
      int availableCars = 0;
      int auctionCars = 0;
      int soldCars = 0;
      int unavailableCars = 0;

      for (var car in carsResponse) {
        final status = car['status'];
        if (status is bool) {
          // Handle boolean status (old schema)
          if (status == true) {
            availableCars++;
          } else {
            unavailableCars++;
          }
        } else if (status is int) {
          // Handle integer status (new schema)
          switch (status) {
            case 1:
              availableCars++;
              break;
            case 2:
              unavailableCars++;
              break;
            case 3:
              auctionCars++;
              break;
            case 4:
              soldCars++;
              break;
          }
        }
      }

      // Get total users count using simple function
      int totalUsers = 0;
      try {
        totalUsers = await _supabaseService.getUserCount();
      } catch (e) {
        print('Error loading users: $e');
        totalUsers = 0;
      }

      // Get total admins count
      int totalAdmins = 0;
      try {
        final adminResponse = await supabase.from('admin').select('*');
        totalAdmins = adminResponse.length;
      } catch (e) {
        print('Error loading admins: $e');
        totalAdmins = 0;
      }

      // Get total posts count
      final postsResponse = await supabase.from('posts').select('*');
      final totalPosts = postsResponse.length;

      // Get total comments count
      final commentsResponse = await supabase.from('comments').select('*');
      final totalComments = commentsResponse.length;

      // Get average car price
      double avgPrice = 0;
      if (carsResponse.isNotEmpty) {
        final prices = carsResponse
            .map((car) => (car['price'] as num).toDouble())
            .toList();
        avgPrice = prices.reduce((a, b) => a + b) / prices.length;
      }

      // Get cars added today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayCarsResponse = await supabase
          .from('cars')
          .select('*')
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());
      final todayCars = todayCarsResponse.length;

      // Get cars added this week
      final weekAgo = today.subtract(const Duration(days: 7));
      final weekCarsResponse = await supabase
          .from('cars')
          .select('*')
          .gte('created_at', weekAgo.toIso8601String());
      final weekCars = weekCarsResponse.length;

      // Get cars added this month
      final monthAgo = DateTime(today.year, today.month - 1, today.day);
      final monthCarsResponse = await supabase
          .from('cars')
          .select('*')
          .gte('created_at', monthAgo.toIso8601String());
      final monthCars = monthCarsResponse.length;

      setState(() {
        _statistics = {
          'totalCars': totalCars,
          'availableCars': availableCars,
          'auctionCars': auctionCars,
          'soldCars': soldCars,
          'unavailableCars': unavailableCars,
          'totalUsers': totalUsers,
          'totalAdmins': totalAdmins,
          'totalPosts': totalPosts,
          'totalComments': totalComments,
          'avgPrice': avgPrice,
          'todayCars': todayCars,
          'weekCars': weekCars,
          'monthCars': monthCars,
        };
      });
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> _loadRecentCars() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('cars')
          .select('car_id, brand, model, year, price, status, created_at')
          .order('created_at', ascending: false)
          .limit(5);

      setState(() {
        _recentCars = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading recent cars: $e');
      setState(() {
        _recentCars = [];
      });
    }
  }

  Future<void> _loadRecentUsers() async {
    try {
      final recentUsers = await _supabaseService.getRecentUsers(limit: 5);
      setState(() {
        _recentUsers = recentUsers;
      });
    } catch (e) {
      print('Error loading recent users: $e');
      setState(() {
        _recentUsers = [];
      });
    }
  }

  Future<void> _loadRecentPosts() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('posts')
          .select('id, text, likes, created_at')
          .order('created_at', ascending: false)
          .limit(5);

      setState(() {
        _recentPosts = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading recent posts: $e');
      setState(() {
        _recentPosts = [];
      });
    }
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

          // Statistics Cards
          _buildStatisticsCards(),

          const SizedBox(height: 24),

          // Recent Activity Section
          _buildRecentActivitySection(),

          const SizedBox(height: 24),

          // Quick Actions Section
          _buildQuickActionsSection(),

          const SizedBox(height: 24),
        ],
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
                Icon(
                  Icons.dashboard,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Admin Dashboard',
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
                  onPressed: _loadDashboardData,
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

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics Overview',
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Cars',
              _statistics['totalCars']?.toString() ?? '0',
              Icons.directions_car,
              Colors.blue,
            ),
            _buildStatCard(
              'Available Cars',
              _statistics['availableCars']?.toString() ?? '0',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Auction Cars',
              _statistics['auctionCars']?.toString() ?? '0',
              Icons.gavel,
              Colors.orange,
            ),
            _buildStatCard(
              'Sold Cars',
              _statistics['soldCars']?.toString() ?? '0',
              Icons.sell,
              Colors.red,
            ),
            _buildStatCard(
              'Total Users',
              _statistics['totalUsers']?.toString() ?? '0',
              Icons.people,
              Colors.purple,
            ),
            _buildStatCard(
              'Total Admins',
              _statistics['totalAdmins']?.toString() ?? '0',
              Icons.admin_panel_settings,
              Colors.deepPurple,
            ),
            _buildStatCard(
              'Total Posts',
              _statistics['totalPosts']?.toString() ?? '0',
              Icons.post_add,
              Colors.teal,
            ),
            _buildStatCard(
              'Avg Price',
              '\$${(_statistics['avgPrice'] ?? 0).toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.amber,
            ),
            _buildStatCard(
              'Today\'s Cars',
              _statistics['todayCars']?.toString() ?? '0',
              Icons.today,
              Colors.indigo,
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
              Icon(
                Icons.trending_up,
                color: color.withOpacity(0.7),
                size: 16,
              ),
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

  Widget _buildRecentActivitySection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : custom_theme.light.shade800,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              // Recent Cars
              _buildActivityItem(
                'Recent Cars',
                _recentCars,
                Icons.directions_car,
                Colors.blue,
                (car) => '${car['brand']} ${car['model']} (${car['year']})',
              ),
              const SizedBox(height: 16),
              // Recent Users
              _buildActivityItem(
                'Recent Users',
                _recentUsers,
                Icons.people,
                Colors.purple,
                (user) => user['email'] ?? 'Unknown',
              ),
              const SizedBox(height: 16),
              // Recent Posts
              _buildActivityItem(
                'Recent Posts',
                _recentPosts,
                Icons.post_add,
                Colors.teal,
                (post) => (post['text'] as String? ?? '').length > 50
                    ? '${(post['text'] as String).substring(0, 50)}...'
                    : post['text'] ?? 'No text',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    List<Map<String, dynamic>> items,
    IconData icon,
    Color color,
    String Function(Map<String, dynamic>) itemFormatter,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : colorScheme.onSurface,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'No recent ${title.toLowerCase()}',
            style: TextStyle(
              fontSize: 14,
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.grey[600],
              fontFamily: 'Tajawal',
            ),
          )
        else
          ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${itemFormatter(item)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[700],
                    fontFamily: 'Tajawal',
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : custom_theme.light.shade800,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Add New Car',
                Icons.add_circle,
                Colors.green,
                () {
                  AddCarDialog.show(context);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                'View All Cars',
                Icons.list,
                Colors.blue,
                () {
                  // Cars tab is at index 1 when admin is true, index 0 when admin is false
                  // Since this is the dashboard (admin only), cars tab is at index 1
                  widget.onNavigateToTab(1);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Manage Users',
                Icons.people_outline,
                Colors.purple,
                () {
                  UsersBottomSheet.show(context);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                'View Reports',
                Icons.analytics,
                Colors.orange,
                () {
                  _showReportsComingSoon();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : colorScheme.onSurface,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportsComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.analytics,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('Reports'),
          ],
        ),
        content: const Text(
          'The reports feature is coming soon! This will include detailed analytics and insights about your car listings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
