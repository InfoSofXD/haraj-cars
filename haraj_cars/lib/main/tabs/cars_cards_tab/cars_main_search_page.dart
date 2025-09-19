import 'package:flutter/material.dart';
import 'package:haraj/features/logger/domain/models/log_entry.dart';
import 'dart:ui';
import '../../../models/car.dart';
import '../../../../supabase/supabase_service.dart';
import '../favorits_tab/favorites_service.dart';
import '../../../../tools/connectivity.dart';
import 'ui/car_card.dart';
import '../../../../tools/Palette/theme.dart' as custom_theme;
import '../../../tools/dialogs/dialogs.dart';
import '../../../features/logger/data/providers/logger_provider.dart';

class CarsTab extends StatefulWidget {
  final bool isAdmin;
  final Function(Car) onEditCar;
  final Function(Car) onDeleteCar;
  final Function(Car) onShowCarDetails;
  final Function(Car) onShowStatusUpdate;

  const CarsTab({
    Key? key,
    required this.isAdmin,
    required this.onEditCar,
    required this.onDeleteCar,
    required this.onShowCarDetails,
    required this.onShowStatusUpdate,
  }) : super(key: key);

  @override
  State<CarsTab> createState() => _CarsTabState();
}

class _CarsTabState extends State<CarsTab> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  List<Car> _auctionCars = [];
  bool _isLoading = true;
  bool _isOnline = true;
  bool _showAuctionList = true; // Toggle for auction list visibility
  Set<String> _favoriteCarIds = {};

  // Filter variables
  String _selectedBrand = '';
  String _selectedYear = '';
  String _selectedCondition =
      ''; // 'new', 'like-new', 'good', 'fair', 'high-mileage', 'custom-range', or ''
  int _selectedStatus =
      0; // 0 = all, 1 = available, 2 = unavailable, 3 = auction, 4 = sold
  RangeValues _priceRange = const RangeValues(0, 200000);
  RangeValues _customConditionRange =
      const RangeValues(0, 200000); // For custom condition range
  RangeValues _likeNewRange = const RangeValues(0, 30000);
  RangeValues _goodRange = const RangeValues(30000, 60000);
  RangeValues _fairRange = const RangeValues(60000, 100000);
  RangeValues _highMileageRange = const RangeValues(100000, 500000);
  bool _showPriceFilter = false;
  bool _showCustomConditionRange = false;

  // Dynamic ranges based on actual data
  double _minPrice = 0;
  double _maxPrice = 200000;
  double _minMileage = 0;
  double _maxMileage = 200000;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _loadCars();
    await _loadFavoriteStatus();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await ConnectivityUtil.isOnline();
    setState(() {
      _isOnline = isOnline;
    });
  }

  Future<void> _loadCars() async {
    if (!_isOnline) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cars = await _supabaseService.getCars();
      setState(() {
        _cars = cars;
        _filteredCars = cars;
        _auctionCars = cars.where((car) => car.status == 3).toList();
        _isLoading = false;
      });
      _calculateDynamicRanges();
      
      // Log car viewing action
      await LoggerProvider.instance.logCarAction(
        action: LogAction.carViewed,
        message: 'Viewed ${cars.length} cars',
        metadata: {
          'car_count': cars.length,
          'auction_cars': cars.where((car) => car.status == 3).length,
          'is_admin': widget.isAdmin,
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading cars: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateDynamicRanges() {
    if (_cars.isEmpty) return;

    // Calculate price range
    final prices = _cars.map((car) => car.price).toList();
    _minPrice = prices.reduce((a, b) => a < b ? a : b);
    _maxPrice = prices.reduce((a, b) => a > b ? a : b);

    // Calculate mileage range (all cars)
    if (_cars.isNotEmpty) {
      final mileages = _cars.map((car) => car.mileage.toDouble()).toList();
      _minMileage = mileages.reduce((a, b) => a < b ? a : b);
      _maxMileage = mileages.reduce((a, b) => a > b ? a : b);
    } else {
      _minMileage = 0;
      _maxMileage = 0;
    }

    // Update range values
    setState(() {
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _customConditionRange = RangeValues(_minMileage, _maxMileage);
      // Keep condition ranges with their own fixed limits, not limited by data
      _likeNewRange = const RangeValues(0, 30000);
      _goodRange = const RangeValues(30000, 60000);
      _fairRange = const RangeValues(60000, 100000);
      _highMileageRange = const RangeValues(100000, 500000);
    });
  }

  Future<void> _reloadCars() async {
    // Clear search and filters when reloading
    _searchController.clear();
    setState(() {
      _selectedBrand = '';
      _selectedYear = '';
      _selectedCondition = '';
      _selectedStatus = 0;
      _showPriceFilter = false;
      _showCustomConditionRange = false;
    });
    await _loadCars();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cars list refreshed'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _searchCars(String query) {
    if (query.isEmpty) {
      _applyFilters();
      return;
    }

    setState(() {
      _filteredCars = _cars.where((car) {
        final searchLower = query.toLowerCase();
        return car.computedTitle.toLowerCase().contains(searchLower) ||
            car.description.toLowerCase().contains(searchLower);
      }).toList();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredCars = _cars.where((car) {
        // Brand filter
        bool matchesBrand =
            _selectedBrand.isEmpty || car.brand == _selectedBrand;

        // Year filter
        bool matchesYear =
            _selectedYear.isEmpty || car.year.toString() == _selectedYear;

        // Status filter
        bool matchesStatus =
            _selectedStatus == 0 || car.status == _selectedStatus;

        // Condition filter based on mileage
        bool matchesCondition = true;
        if (_selectedCondition.isNotEmpty) {
          if (_selectedCondition == 'new') {
            matchesCondition = car.mileage == 0;
          } else if (_selectedCondition == 'like-new') {
            matchesCondition = car.mileage >= _likeNewRange.start &&
                car.mileage <= _likeNewRange.end;
          } else if (_selectedCondition == 'good') {
            matchesCondition = car.mileage >= _goodRange.start &&
                car.mileage <= _goodRange.end;
          } else if (_selectedCondition == 'fair') {
            matchesCondition = car.mileage >= _fairRange.start &&
                car.mileage <= _fairRange.end;
          } else if (_selectedCondition == 'high-mileage') {
            matchesCondition = car.mileage >= _highMileageRange.start &&
                car.mileage <= _highMileageRange.end;
          } else if (_selectedCondition == 'custom-range') {
            matchesCondition = car.mileage >= _customConditionRange.start &&
                car.mileage <= _customConditionRange.end;
          }
        }

        // Mileage filter (only for custom range)
        bool matchesMileage = true;
        if (_selectedCondition == 'custom-range') {
          matchesMileage = car.mileage >= _customConditionRange.start &&
              car.mileage <= _customConditionRange.end;
        }

        // Price filter
        bool matchesPrice =
            car.price >= _priceRange.start && car.price <= _priceRange.end;

        return matchesBrand &&
            matchesYear &&
            matchesStatus &&
            matchesCondition &&
            matchesMileage &&
            matchesPrice;
      }).toList();
    });
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final service = await FavoritesService.getInstance();
      final favoriteCars = await service.getFavoriteCars();
      setState(() {
        _favoriteCarIds = favoriteCars.map((car) => car.carId).toSet();
      });
    } catch (e) {
      print('Error loading favorite status: $e');
    }
  }

  Future<void> _toggleFavorite(Car car) async {
    try {
      final service = await FavoritesService.getInstance();
      final success = await service.toggleFavorite(car);
      if (success) {
        setState(() {
          if (_favoriteCarIds.contains(car.carId)) {
            _favoriteCarIds.remove(car.carId);
          } else {
            _favoriteCarIds.add(car.carId);
          }
        });

        if (mounted) {
          final isFavorite = _favoriteCarIds.contains(car.carId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isFavorite ? 'Added to favorites' : 'Removed from favorites'),
              backgroundColor: isFavorite ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              // Auction cars horizontal list
              if (_auctionCars.isNotEmpty && mounted) _buildAuctionList(),
              // Main car list (full screen, content scrolls under floating elements)
              Expanded(
                child: _buildCarsList(),
              ),
            ],
          ),

          // Floating Title, Search and Filter Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildSearchBar(),
                _buildFilterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionList() {
    if (!mounted || _auctionCars.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      key: const ValueKey('auction_section'),
      margin: const EdgeInsets.only(top: 200, left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auction title with toggle button
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auction Cars${!_showAuctionList ? ' (${_auctionCars.length})' : ''}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : custom_theme.light.shade800,
                    fontFamily: 'Tajawal',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAuctionList = !_showAuctionList;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : custom_theme.light.shade200.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.3)
                            : custom_theme.light.shade400,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _showAuctionList
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : custom_theme.light.shade700,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Horizontal list of auction cars
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showAuctionList ? 350 : 0,
            child: _showAuctionList
                ? ListView.builder(
                    key: const ValueKey('auction_list'),
                    scrollDirection: Axis.horizontal,
                    itemCount: _auctionCars.length,
                    itemBuilder: (context, index) {
                      if (index >= _auctionCars.length) {
                        return const SizedBox.shrink();
                      }
                      final car = _auctionCars[index];
                      return Container(
                        key: ValueKey('auction_car_${car.carId}'),
                        width: 280,
                        height: 330, // Match the CarCard height
                        margin: const EdgeInsets.only(right: 16),
                        child: CarCard(
                          car: car,
                          isFavorite: _favoriteCarIds.contains(car.carId),
                          isAdmin: widget.isAdmin,
                          onTap: () => widget.onShowCarDetails(car),
                          onToggleFavorite: () => _toggleFavorite(car),
                          onEdit: () => widget.onEditCar(car),
                          onDelete: () => widget.onDeleteCar(car),
                          onStatusUpdate: () => widget.onShowStatusUpdate(car),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCarsList() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    if (_filteredCars.isEmpty) {
      return Center(
        child: Text(
          'No cars found',
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
            fontFamily: 'Tajawal',
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate number of columns based on screen width
        int crossAxisCount;
        double childAspectRatio;

        // Calculate optimal number of columns based on minimum card width
        double minCardWidth = 280; // Minimum card width for good readability
        double availableWidth =
            constraints.maxWidth - 32; // Account for padding

        // Calculate how many cards can fit
        crossAxisCount = ((availableWidth + 16) / (minCardWidth + 16)).floor();

        // Ensure at least 1 column
        if (crossAxisCount < 1) crossAxisCount = 1;

        // Calculate actual card width and aspect ratio for fixed 330px height
        double cardWidth =
            (availableWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        childAspectRatio = cardWidth / 330;

        return GridView.builder(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: _auctionCars.isNotEmpty
                ? (0) // 200 + 20 + 12 for collapsed (margin + title + padding)
                : 200.0, // 200 for no auction list
            bottom: 100,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _filteredCars.length,
          itemBuilder: (context, index) {
            final car = _filteredCars[index];
            return CarCard(
              car: car,
              isFavorite: _favoriteCarIds.contains(car.carId),
              isAdmin: widget.isAdmin,
              onTap: () => widget.onShowCarDetails(car),
              onToggleFavorite: () => _toggleFavorite(car),
              onEdit: () => widget.onEditCar(car),
              onDelete: () => widget.onDeleteCar(car),
              onStatusUpdate: () => widget.onShowStatusUpdate(car),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : custom_theme.light.shade800,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for carsxv...',
                      hintStyle: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : custom_theme.light.shade600,
                        fontSize: 16,
                        fontFamily: 'Tajawal',
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : custom_theme.light.shade700,
                        size: 24,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    onChanged: _searchCars,
                  ),
                ),
                // Reload button
                GestureDetector(
                  onTap: _isLoading ? null : _reloadCars,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.2)
                          : custom_theme.light.shade200.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : custom_theme.light.shade700,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.refresh,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : custom_theme.light.shade700,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                // Filter Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFilterIcon(Icons.new_releases, 'CONDITION'),
                    _buildFilterIcon(Icons.calendar_today, 'YEAR'),
                    _buildFilterIcon(Icons.directions_car, 'BRAND'),
                    _buildFilterIcon(Icons.info, 'STATUS'),
                    _buildFilterIcon(Icons.local_offer, 'PRICE'),
                  ],
                ),
                const SizedBox(height: 12),
                // Filter Buttons
                Row(
                  children: [
                    Expanded(child: _buildConditionFilter()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildYearFilter()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildBrandFilter()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatusFilter()),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPriceFilter()),
                  ],
                ),
                // Advanced filters
                if (_showPriceFilter ||
                    _showCustomConditionRange ||
                    _shouldShowConditionRange()) ...[
                  const SizedBox(height: 16),
                  if (_showPriceFilter) _buildPriceRangeFilter(),
                  if (_showCustomConditionRange)
                    _buildCustomConditionRangeFilter(),
                  if (_shouldShowConditionRange() && !_showCustomConditionRange)
                    _buildConditionRangeDisplay(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterIcon(IconData icon, String label) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.8)
                : custom_theme.light.shade700,
            size: 24),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.7)
                  : custom_theme.light.shade600,
              fontSize: 10,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildConditionFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedCondition.isNotEmpty;

    return GestureDetector(
      onTap: () => _showConditionFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ]
                : theme.brightness == Brightness.dark
                    ? [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        custom_theme.light.shade200.withOpacity(0.3),
                        custom_theme.light.shade100.withOpacity(0.5),
                      ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : custom_theme.light.shade400,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          _selectedCondition.isEmpty
              ? 'ALL'
              : _selectedCondition == 'custom-range'
                  ? 'CUSTOM RANGE'
                  : _getConditionDisplayText(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            color: isSelected
                ? Colors.white
                : theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.8)
                    : custom_theme.light.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildYearFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedYear.isNotEmpty;

    return GestureDetector(
      onTap: () => _showYearFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.primary)
              : theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.2)
                  : custom_theme.light.shade200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? (theme.brightness == Brightness.dark
                    ? Colors.white
                    : colorScheme.primary)
                : theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : custom_theme.light.shade400,
            width: 1,
          ),
        ),
        child: Text(
          _selectedYear.isEmpty ? 'YEAR' : _selectedYear,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            color: isSelected
                ? (theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white)
                : theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBrandFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedBrand.isNotEmpty;

    return GestureDetector(
      onTap: () => _showBrandFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.primary)
              : theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.2)
                  : custom_theme.light.shade200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? (theme.brightness == Brightness.dark
                    ? Colors.white
                    : colorScheme.primary)
                : theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : custom_theme.light.shade400,
            width: 1,
          ),
        ),
        child: Text(
          _selectedBrand.isEmpty ? 'BRAND' : _selectedBrand,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            color: isSelected
                ? (theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white)
                : theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPriceFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDefaultRange =
        _priceRange.start == _minPrice && _priceRange.end == _maxPrice;
    final isSelected = !isDefaultRange;

    return GestureDetector(
      onTap: () => _togglePriceFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.primary)
              : theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.2)
                  : custom_theme.light.shade200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? (theme.brightness == Brightness.dark
                    ? Colors.white
                    : colorScheme.primary)
                : theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : custom_theme.light.shade400,
            width: 1,
          ),
        ),
        child: Text(
          isDefaultRange
              ? 'PRICE'
              : '\$${_priceRange.start.round()}-\$${_priceRange.end.round()}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            color: isSelected
                ? (theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white)
                : theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: _minPrice,
            max: _maxPrice,
            divisions: (_maxPrice - _minPrice).round() > 0
                ? (_maxPrice - _minPrice).round()
                : 1,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
              _applyFilters();
            },
          ),
          Text(
            'Range: \$${_minPrice.round()} - \$${_maxPrice.round()}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomConditionRangeFilter() {
    // Ensure we have valid min/max values
    final minMileage = _minMileage.isFinite ? _minMileage : 0.0;
    final maxMileage = _maxMileage.isFinite && _maxMileage > minMileage
        ? _maxMileage
        : minMileage + 1000.0;

    // Ensure range values are within bounds
    final safeRange = RangeValues(
      _customConditionRange.start.clamp(minMileage, maxMileage),
      _customConditionRange.end.clamp(minMileage, maxMileage),
    );

    // Update the range if it was out of bounds
    if (safeRange != _customConditionRange) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _customConditionRange = safeRange;
        });
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mileage Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: safeRange,
            min: minMileage,
            max: maxMileage,
            divisions: (maxMileage - minMileage).round() > 0
                ? (maxMileage - minMileage).round()
                : 1,
            labels: RangeLabels(
              '${safeRange.start.round()}k',
              '${safeRange.end.round()}k',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _customConditionRange = values;
              });
              _applyFilters();
            },
          ),
          Text(
            'Range: ${minMileage.round()}k - ${maxMileage.round()}k miles',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cars in range: ${_getCustomConditionRangeCount()}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.purple,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  int _getCustomConditionRangeCount() {
    // Ensure we have valid min/max values
    final minMileage = _minMileage.isFinite ? _minMileage : 0.0;
    final maxMileage = _maxMileage.isFinite && _maxMileage > minMileage
        ? _maxMileage
        : minMileage + 1000.0;

    final safeRange = RangeValues(
      _customConditionRange.start.clamp(minMileage, maxMileage),
      _customConditionRange.end.clamp(minMileage, maxMileage),
    );

    return _cars
        .where((car) =>
            car.mileage >= safeRange.start && car.mileage <= safeRange.end)
        .length;
  }

  String _getConditionDisplayText() {
    switch (_selectedCondition) {
      case 'new':
        return 'NEW (0 MILES)';
      case 'like-new':
        return 'LIKE NEW (0-30K)';
      case 'good':
        return 'GOOD (30K-60K)';
      case 'fair':
        return 'FAIR (60K-100K)';
      case 'high-mileage':
        return 'HIGH MILEAGE (100K+)';
      default:
        return _selectedCondition.replaceAll('-', ' ').toUpperCase();
    }
  }

  bool _shouldShowConditionRange() {
    return _selectedCondition.isNotEmpty &&
        _selectedCondition != 'new' &&
        _selectedCondition != 'custom-range';
  }

  Widget _buildConditionRangeDisplay() {
    RangeValues conditionRange;
    Color rangeColor = Colors.grey;
    String rangeTitle = '';
    double minValue = 0;
    double maxValue = 200000;

    switch (_selectedCondition) {
      case 'like-new':
        conditionRange = _likeNewRange;
        rangeColor = Colors.blue;
        rangeTitle = 'Like New Range';
        minValue = 0;
        maxValue = 50000;
        break;
      case 'good':
        conditionRange = _goodRange;
        rangeColor = Colors.orange;
        rangeTitle = 'Good Range';
        minValue = 0;
        maxValue = 100000;
        break;
      case 'fair':
        conditionRange = _fairRange;
        rangeColor = Colors.amber;
        rangeTitle = 'Fair Range';
        minValue = 0;
        maxValue = 200000;
        break;
      case 'high-mileage':
        conditionRange = _highMileageRange;
        rangeColor = Colors.red;
        rangeTitle = 'High Mileage Range';
        minValue = 50000;
        maxValue = 500000;
        break;
      default:
        conditionRange = const RangeValues(0, 100000);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rangeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rangeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rangeTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: conditionRange,
            min: minValue,
            max: maxValue,
            divisions: (maxValue - minValue).round() > 0
                ? (maxValue - minValue).round()
                : 1,
            labels: RangeLabels(
              '${conditionRange.start.round()}k',
              '${conditionRange.end.round()}k',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                switch (_selectedCondition) {
                  case 'like-new':
                    _likeNewRange = values;
                    break;
                  case 'good':
                    _goodRange = values;
                    break;
                  case 'fair':
                    _fairRange = values;
                    break;
                  case 'high-mileage':
                    _highMileageRange = values;
                    break;
                }
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${conditionRange.start.round()}k',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontFamily: 'Tajawal',
                ),
              ),
              Text(
                'Max: ${conditionRange.end.round()}k',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Cars in this range: ${_getConditionRangeCount()}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: rangeColor,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  int _getConditionRangeCount() {
    switch (_selectedCondition) {
      case 'like-new':
        return _cars
            .where((car) =>
                car.mileage >= _likeNewRange.start &&
                car.mileage <= _likeNewRange.end)
            .length;
      case 'good':
        return _cars
            .where((car) =>
                car.mileage >= _goodRange.start &&
                car.mileage <= _goodRange.end)
            .length;
      case 'fair':
        return _cars
            .where((car) =>
                car.mileage >= _fairRange.start &&
                car.mileage <= _fairRange.end)
            .length;
      case 'high-mileage':
        return _cars
            .where((car) =>
                car.mileage >= _highMileageRange.start &&
                car.mileage <= _highMileageRange.end)
            .length;
      default:
        return 0;
    }
  }

  void _showConditionFilter() {
    showDialog(
      context: context,
      builder: (context) => ConditionFilterDialog(
        cars: _cars,
        selectedCondition: _selectedCondition,
        onConditionSelected: (value, rangeValues) {
          setState(() {
            _selectedCondition = value;
            // If custom range is selected, show the range selector and update values
            if (value == 'custom-range') {
              _showCustomConditionRange = true;
              if (rangeValues != null) {
                _customConditionRange = rangeValues;
              } else {
                // Initialize with current data range if no range provided
                _customConditionRange = RangeValues(_minMileage, _maxMileage);
              }
            } else {
              _showCustomConditionRange = false;
            }
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showYearFilter() {
    YearFilterDialog.show(
      context,
      cars: _cars,
      selectedYear: _selectedYear,
      onYearSelected: (value) {
        setState(() {
          _selectedYear = value;
        });
        _applyFilters();
      },
    );
  }

  void _showBrandFilter() {
    BrandFilterDialog.show(
      context,
      cars: _cars,
      selectedBrand: _selectedBrand,
      onBrandSelected: (value) {
        setState(() {
          _selectedBrand = value;
        });
        _applyFilters();
      },
    );
  }

  void _togglePriceFilter() {
    setState(() {
      _showPriceFilter = !_showPriceFilter;
    });
  }

  Widget _buildStatusFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedStatus != 0;

    String statusText = 'STATUS';
    if (_selectedStatus == 1) {
      statusText = 'AVAILABLE';
    } else if (_selectedStatus == 2) {
      statusText = 'UNAVAILABLE';
    } else if (_selectedStatus == 3) {
      statusText = 'AUCTION';
    } else if (_selectedStatus == 4) {
      statusText = 'SOLD';
    }

    return GestureDetector(
      onTap: () => _showStatusFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (theme.brightness == Brightness.dark
                  ? Colors.white
                  : colorScheme.primary)
              : theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.2)
                  : custom_theme.light.shade200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? (theme.brightness == Brightness.dark
                    ? Colors.white
                    : colorScheme.primary)
                : theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : custom_theme.light.shade400,
            width: 1,
          ),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            color: isSelected
                ? (theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white)
                : theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showStatusFilter() {
    StatusFilterDialog.show(
      context,
      cars: _cars,
      selectedStatus: _selectedStatus,
      onStatusSelected: (value) {
        setState(() {
          _selectedStatus = value;
        });
        _applyFilters();
      },
    );
  }
}
