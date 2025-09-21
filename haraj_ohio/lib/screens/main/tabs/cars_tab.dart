import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../models/car.dart';
import '../../../../supabase/supabase_service.dart';
import '../../../services/favorites_service.dart';
import '../../../../tools/connectivity.dart';
import '../../../tools/cards/car_card.dart';
import '../../../tools/cards/auction_cars_card.dart';
import '../../../../tools/Palette/theme.dart' as custom_theme;
import '../../../widgets/filter_widget.dart';
import '../../info_screen.dart';
import '../../global_sites_screen.dart';

class CarsTab extends StatefulWidget {
  final bool isAdmin;
  final Function(Car) onEditCar;
  final Function(Car) onDeleteCar;
  final Function(Car) onShowCarDetails;
  final Function(Car) onShowStatusUpdate;
  final PageController? pageController;

  const CarsTab({
    Key? key,
    required this.isAdmin,
    required this.onEditCar,
    required this.onDeleteCar,
    required this.onShowCarDetails,
    required this.onShowStatusUpdate,
    this.pageController,
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

  // Filter state
  String _selectedBrand = '';
  String _selectedYear = '';
  String _selectedCondition = '';
  int _selectedStatus = 0;
  RangeValues _priceRange = const RangeValues(0, 200000);
  RangeValues _customConditionRange = const RangeValues(0, 200000);
  RangeValues _likeNewRange = const RangeValues(0, 30000);
  RangeValues _goodRange = const RangeValues(30000, 60000);
  RangeValues _fairRange = const RangeValues(60000, 100000);
  RangeValues _highMileageRange = const RangeValues(100000, 500000);
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

      // Calculate price and mileage ranges from actual data
      if (cars.isNotEmpty) {
        final prices = cars.map((car) => car.price).toList();
        final mileages = cars.map((car) => car.mileage.toDouble()).toList();

        _minPrice = prices.reduce((a, b) => a < b ? a : b);
        _maxPrice = prices.reduce((a, b) => a > b ? a : b);
        _minMileage = mileages.reduce((a, b) => a < b ? a : b);
        _maxMileage = mileages.reduce((a, b) => a > b ? a : b);

        // Update price range to match data
        _priceRange = RangeValues(_minPrice, _maxPrice);
        _customConditionRange = RangeValues(_minMileage, _maxMileage);
      }

      setState(() {
        _cars = cars;
        _filteredCars = cars;
        _auctionCars = cars.where((car) => car.status == 3).toList();
        _isLoading = false;
      });

      // Apply current filters after loading
      _applyFilters();
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

  Future<void> _reloadCars() async {
    // Clear search and filters when reloading
    _searchController.clear();
    _clearAllFilters();
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
    _applyFilters(query);
  }

  void _applyFilters([String? searchQuery]) {
    setState(() {
      _filteredCars = _cars.where((car) {
        // Search filter
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final searchLower = searchQuery.toLowerCase();
          if (!car.computedTitle.toLowerCase().contains(searchLower) &&
              !car.description.toLowerCase().contains(searchLower)) {
            return false;
          }
        } else if (_searchController.text.isNotEmpty) {
          final searchLower = _searchController.text.toLowerCase();
          if (!car.computedTitle.toLowerCase().contains(searchLower) &&
              !car.description.toLowerCase().contains(searchLower)) {
            return false;
          }
        }

        // Brand filter
        if (_selectedBrand.isNotEmpty && car.brand != _selectedBrand) {
          return false;
        }

        // Year filter
        if (_selectedYear.isNotEmpty && car.year.toString() != _selectedYear) {
          return false;
        }

        // Status filter
        if (_selectedStatus != 0 && car.status != _selectedStatus) {
          return false;
        }

        // Price filter
        if (car.price < _priceRange.start || car.price > _priceRange.end) {
          return false;
        }

        // Condition filter
        if (_selectedCondition.isNotEmpty) {
          switch (_selectedCondition) {
            case 'new':
              if (car.mileage != 0) return false;
              break;
            case 'like-new':
              if (car.mileage < 0 || car.mileage > 30000) return false;
              break;
            case 'good':
              if (car.mileage < 30000 || car.mileage > 60000) return false;
              break;
            case 'fair':
              if (car.mileage < 60000 || car.mileage > 100000) return false;
              break;
            case 'high-mileage':
              if (car.mileage < 100000) return false;
              break;
            case 'custom-range':
              if (car.mileage < _customConditionRange.start ||
                  car.mileage > _customConditionRange.end) return false;
              break;
          }
        }

        return true;
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

  Widget _buildBrandingContainer() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            height: 120,
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Image slot 1
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[600]!.withOpacity(0.3)
                            : custom_theme.light.shade200.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.2)
                              : custom_theme.light.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 32,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.5)
                              : custom_theme.light.shade500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Image slot 2
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[600]!.withOpacity(0.3)
                            : custom_theme.light.shade200.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.2)
                              : custom_theme.light.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 32,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.5)
                              : custom_theme.light.shade500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Image slot 3
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey[600]!.withOpacity(0.3)
                            : custom_theme.light.shade200.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.2)
                              : custom_theme.light.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 32,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.5)
                              : custom_theme.light.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionList() {
    final hasActiveFilters = _selectedBrand.isNotEmpty ||
        _selectedYear.isNotEmpty ||
        _selectedCondition.isNotEmpty ||
        _selectedStatus != 0 ||
        _priceRange.start != _minPrice ||
        _priceRange.end != _maxPrice;

    final isSearching = _searchController.text.isNotEmpty;

    // Hide auction list when filters are applied or when searching
    if (!mounted || _auctionCars.isEmpty || hasActiveFilters || isSearching) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      key: const ValueKey('auction_section'),
      margin: const EdgeInsets.fromLTRB(0, 210, 0, 8),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[700]!.withOpacity(0.3)
                  : custom_theme.light.shade100.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : custom_theme.light.shade300,
                  width: 1,
                ),
                bottom: BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : custom_theme.light.shade300,
                  width: 1,
                ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Auction title with toggle button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Auction Cars${!_showAuctionList ? ' (${_auctionCars.length})' : ''}',
                        style: TextStyle(
                          fontSize: 18,
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
                // Auction cars with navigation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _showAuctionList
                      ? 220
                      : 0, // Adjusted height for smaller cards
                  child: _showAuctionList
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16),
                          child: AuctionCarsCard(
                            cars: _auctionCars,
                            favoriteCarIds: _favoriteCarIds,
                            isAdmin: widget.isAdmin,
                            onTap: widget.onShowCarDetails,
                            onToggleFavorite: _toggleFavorite,
                            onEdit: widget.onEditCar,
                            onDelete: widget.onDeleteCar,
                            onStatusUpdate: widget.onShowStatusUpdate,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarsList() {
    final theme = Theme.of(context);
    final hasActiveFilters = _selectedBrand.isNotEmpty ||
        _selectedYear.isNotEmpty ||
        _selectedCondition.isNotEmpty ||
        _selectedStatus != 0 ||
        _priceRange.start != _minPrice ||
        _priceRange.end != _maxPrice;

    final isSearching = _searchController.text.isNotEmpty;

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

        // Ensure at least 2 columns
        if (crossAxisCount < 2) crossAxisCount = 2;

        // Calculate actual card width and aspect ratio for fixed 330px height
        double cardWidth =
            (availableWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        childAspectRatio = cardWidth / 330;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: hasActiveFilters
                ? 300
                : isSearching
                    ? 200
                    : 80,
            bottom: 80,
          ),
          child: Column(
            children: [
              // Auction list at the top (full width)
              if (_auctionCars.isNotEmpty) _buildAuctionList(),
              const SizedBox(height: 16),
              // Cars grid with padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final hasActiveFilters = _selectedBrand.isNotEmpty ||
        _selectedYear.isNotEmpty ||
        _selectedCondition.isNotEmpty ||
        _selectedStatus != 0 ||
        _priceRange.start != _minPrice ||
        _priceRange.end != _maxPrice;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 3),
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
            child: Column(
              children: [
                // Search bar row
                Row(
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
                          hintText: 'Search for cars...',
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
                    // Filter button
                    GestureDetector(
                      onTap: _showFilterPage,
                      child: Container(
                        margin:
                            const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.2)
                              : custom_theme.light.shade200.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : custom_theme.light.shade700,
                          size: 20,
                        ),
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
                // Filter chips section (connected to search bar)
                if (hasActiveFilters) _buildFilterChipsContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipsContent() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.2)
                : custom_theme.light.shade300.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 18,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : custom_theme.light.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Active Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Tajawal',
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : custom_theme.light.shade800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.red.withOpacity(0.2)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedBrand.isNotEmpty)
                  _buildFilterChip(
                    label: _selectedBrand,
                    onRemove: () => _removeFilter('brand'),
                    icon: Icons.directions_car,
                  ),
                if (_selectedYear.isNotEmpty)
                  _buildFilterChip(
                    label: _selectedYear,
                    onRemove: () => _removeFilter('year'),
                    icon: Icons.calendar_today,
                  ),
                if (_selectedCondition.isNotEmpty)
                  _buildFilterChip(
                    label: _getConditionDisplayText(),
                    onRemove: () => _removeFilter('condition'),
                    icon: Icons.new_releases,
                  ),
                if (_selectedStatus != 0)
                  _buildFilterChip(
                    label: _getStatusDisplayText(),
                    onRemove: () => _removeFilter('status'),
                    icon: Icons.info,
                  ),
                if (_priceRange.start != _minPrice ||
                    _priceRange.end != _maxPrice)
                  _buildFilterChip(
                    label:
                        '\$${_priceRange.start.round()}-\$${_priceRange.end.round()}',
                    onRemove: () => _removeFilter('price'),
                    icon: Icons.local_offer,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasActiveFilters = _selectedBrand.isNotEmpty ||
        _selectedYear.isNotEmpty ||
        _selectedCondition.isNotEmpty ||
        _selectedStatus != 0 ||
        _priceRange.start != _minPrice ||
        _priceRange.end != _maxPrice;

    final isSearching = _searchController.text.isNotEmpty;

    // Hide action buttons when filters are applied or when searching
    if (hasActiveFilters || isSearching) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Button 1
          _buildActionButton(
            icon: Icons.gavel,
            label: 'Toggle Auction',
            onTap: () {
              setState(() {
                _showAuctionList = !_showAuctionList;
              });
            },
          ),
          // Button 2
          _buildActionButton(
            icon: Icons.public,
            label: 'Global Sites',
            onTap: () {
              // Navigate to global sites screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GlobalSitesScreen(),
                ),
              );
            },
          ),
          // Button 3
          _buildActionButton(
            icon: Icons.favorite,
            label: 'Favorites',
            onTap: () {
              // Navigate to favorites tab
              if (widget.pageController != null) {
                widget.pageController!.animateToPage(
                  3, // Favorites tab index
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          // Button 4
          _buildActionButton(
            icon: Icons.lightbulb,
            label: 'Info',
            onTap: () {
              // Navigate to info screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InfoScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getConditionDisplayText() {
    switch (_selectedCondition) {
      case 'new':
        return 'New (0 miles)';
      case 'like-new':
        return 'Like New (0-30K)';
      case 'good':
        return 'Good (30K-60K)';
      case 'fair':
        return 'Fair (60K-100K)';
      case 'high-mileage':
        return 'High Mileage (100K+)';
      case 'custom-range':
        return 'Custom Range';
      default:
        return _selectedCondition.replaceAll('-', ' ').toUpperCase();
    }
  }

  String _getStatusDisplayText() {
    switch (_selectedStatus) {
      case 1:
        return 'Available';
      case 2:
        return 'Unavailable';
      case 3:
        return 'Auction';
      case 4:
        return 'Sold';
      default:
        return 'Unknown';
    }
  }

  void _removeFilter(String filterType) {
    setState(() {
      switch (filterType) {
        case 'brand':
          _selectedBrand = '';
          break;
        case 'year':
          _selectedYear = '';
          break;
        case 'condition':
          _selectedCondition = '';
          break;
        case 'status':
          _selectedStatus = 0;
          break;
        case 'price':
          _priceRange = RangeValues(_minPrice, _maxPrice);
          break;
      }
    });
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedBrand = '';
      _selectedYear = '';
      _selectedCondition = '';
      _selectedStatus = 0;
      _priceRange = RangeValues(_minPrice, _maxPrice);
    });
    _applyFilters();
  }

  void _showFilterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(
          cars: _cars,
          selectedBrand: _selectedBrand,
          selectedYear: _selectedYear,
          selectedCondition: _selectedCondition,
          selectedStatus: _selectedStatus,
          priceRange: _priceRange,
          customConditionRange: _customConditionRange,
          likeNewRange: _likeNewRange,
          goodRange: _goodRange,
          fairRange: _fairRange,
          highMileageRange: _highMileageRange,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          minMileage: _minMileage,
          maxMileage: _maxMileage,
          onFiltersApplied: (brand, year, condition, status, priceRange,
              customRange, likeNew, good, fair, highMileage) {
            setState(() {
              _selectedBrand = brand;
              _selectedYear = year;
              _selectedCondition = condition;
              _selectedStatus = status;
              _priceRange = priceRange;
              _customConditionRange = customRange;
              _likeNewRange = likeNew;
              _goodRange = good;
              _fairRange = fair;
              _highMileageRange = highMileage;
            });
            _applyFilters();
          },
        ),
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
          // Main car list (expanded to fill remaining space)
          _buildCarsList(),
          // Floating elements
          Column(
            children: [
              // Floating Branding Container
              _buildBrandingContainer(),
              // Floating Search Bar (with integrated filter chips)
              _buildSearchBar(),
              // Floating Action Buttons
              _buildActionButtons(),
            ],
          ),
        ],
      ),
    );
  }
}
