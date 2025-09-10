import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/car.dart';
import '../../../supabase/supabase_service.dart';
import '../../services/favorites_service.dart';
import '../../../tools/connectivity.dart';
import '../../cards/car_card.dart';

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
  bool _isLoading = true;
  bool _isOnline = true;
  Set<String> _favoriteCarIds = {};

  // Filter variables
  String _selectedBrand = '';
  String _selectedYear = '';
  String _selectedCondition = ''; // 'new', 'used', or ''
  RangeValues _mileageRange = const RangeValues(0, 200000);
  RangeValues _priceRange = const RangeValues(0, 200000);
  bool _showMileageFilter = false;
  bool _showPriceFilter = false;

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
        _isLoading = false;
      });
      _calculateDynamicRanges();
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

    // Calculate mileage range (only for used cars)
    final usedCars = _cars.where((car) => !car.condition).toList();
    if (usedCars.isNotEmpty) {
      final mileages = usedCars.map((car) => car.mileage.toDouble()).toList();
      _minMileage = mileages.reduce((a, b) => a < b ? a : b);
      _maxMileage = mileages.reduce((a, b) => a > b ? a : b);
    } else {
      _minMileage = 0;
      _maxMileage = 0;
    }

    // Update range values
    setState(() {
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _mileageRange = RangeValues(_minMileage, _maxMileage);
    });
  }

  Future<void> _reloadCars() async {
    // Clear search and filters when reloading
    _searchController.clear();
    setState(() {
      _selectedBrand = '';
      _selectedYear = '';
      _selectedCondition = '';
      _showMileageFilter = false;
      _showPriceFilter = false;
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

        // Condition filter
        bool matchesCondition = true;
        if (_selectedCondition.isNotEmpty) {
          if (_selectedCondition == 'new') {
            matchesCondition = car.condition; // true = new
          } else if (_selectedCondition == 'used') {
            matchesCondition = !car.condition; // false = used
          }
        }

        // Mileage filter (only for used cars)
        bool matchesMileage = true;
        if (_selectedCondition == 'used' ||
            (_selectedCondition.isEmpty && !car.condition)) {
          matchesMileage = car.mileage >= _mileageRange.start &&
              car.mileage <= _mileageRange.end;
        }

        // Price filter
        bool matchesPrice =
            car.price >= _priceRange.start && car.price <= _priceRange.end;

        return matchesBrand &&
            matchesYear &&
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
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
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

  Widget _buildCarsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2196F3),
        ),
      );
    }

    if (_filteredCars.isEmpty) {
      return const Center(
        child: Text(
          'No cars found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
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
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 200, // Space for floating title/search/filter to hover above
            bottom: 100, // Space for floating bottom nav bar
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
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
              borderRadius: BorderRadius.circular(12),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search for cars...',
                      hintStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Tajawal',
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 24,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            color: Colors.white,
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.all(16),
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
              borderRadius: BorderRadius.circular(12),
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
            child: Column(
              children: [
                // Filter Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFilterIcon(Icons.new_releases, 'CONDITION'),
                    _buildFilterIcon(Icons.calendar_today, 'YEAR'),
                    _buildFilterIcon(Icons.directions_car, 'BRAND'),
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
                    Expanded(child: _buildPriceFilter()),
                  ],
                ),
                // Advanced filters
                if (_showMileageFilter || _showPriceFilter) ...[
                  const SizedBox(height: 16),
                  if (_showMileageFilter && _selectedCondition == 'used')
                    _buildMileageRangeFilter(),
                  if (_showPriceFilter) _buildPriceRangeFilter(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildConditionFilter() {
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
                    const Color(0xFF2196F3),
                    const Color(0xFF1976D2),
                  ]
                : [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF42A5F5)
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF42A5F5).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          _selectedCondition.isEmpty ? 'ALL' : _selectedCondition.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildYearFilter() {
    final isSelected = _selectedYear.isNotEmpty;
    return GestureDetector(
      onTap: () => _showYearFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          _selectedYear.isEmpty ? 'YEAR' : _selectedYear,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBrandFilter() {
    final isSelected = _selectedBrand.isNotEmpty;
    return GestureDetector(
      onTap: () => _showBrandFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          _selectedBrand.isEmpty ? 'BRAND' : _selectedBrand,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPriceFilter() {
    final isDefaultRange =
        _priceRange.start == _minPrice && _priceRange.end == _maxPrice;
    final isSelected = !isDefaultRange;

    return GestureDetector(
      onTap: () => _togglePriceFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
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
            color: isSelected ? const Color(0xFF1976D2) : Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMileageRangeFilter() {
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
            'Mileage Range (for used cars)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _mileageRange,
            min: _minMileage,
            max: _maxMileage,
            divisions: (_maxMileage - _minMileage).round() > 0
                ? (_maxMileage - _minMileage).round()
                : 1,
            labels: RangeLabels(
              '${_mileageRange.start.round()} miles',
              '${_mileageRange.end.round()} miles',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _mileageRange = values;
              });
              _applyFilters();
            },
          ),
          Text(
            'Range: ${_minMileage.round()} - ${_maxMileage.round()} miles',
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
              '₳${_priceRange.start.round()}',
              '₳${_priceRange.end.round()}',
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

  void _showConditionFilter() {
    final newCarsCount = _cars.where((car) => car.condition).length;
    final usedCarsCount = _cars.where((car) => !car.condition).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Condition'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All (${_cars.length} cars)'),
              leading: Radio<String>(
                value: '',
                groupValue: _selectedCondition,
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value!;
                    _showMileageFilter = false;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
            ),
            ListTile(
              title: Text('New (0 miles) ($newCarsCount cars)'),
              leading: Radio<String>(
                value: 'new',
                groupValue: _selectedCondition,
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value!;
                    _showMileageFilter = false;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
            ),
            ListTile(
              title: Text('Used (with mileage) ($usedCarsCount cars)'),
              leading: Radio<String>(
                value: 'used',
                groupValue: _selectedCondition,
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value!;
                    _showMileageFilter = true;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showYearFilter() {
    // Get unique years from actual car data, sorted descending
    final years = _cars.map((car) => car.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final yearStrings = years.map((year) => year.toString()).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Year'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: yearStrings.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('All Years'),
                  leading: Radio<String>(
                    value: '',
                    groupValue: _selectedYear,
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                      Navigator.pop(context);
                      _applyFilters();
                    },
                  ),
                );
              }
              final year = yearStrings[index - 1];
              final carCount =
                  _cars.where((car) => car.year.toString() == year).length;
              return ListTile(
                title: Text('$year ($carCount cars)'),
                leading: Radio<String>(
                  value: year,
                  groupValue: _selectedYear,
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value!;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showBrandFilter() {
    final brands = _cars.map((car) => car.brand).toSet().toList()..sort();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Brand'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: brands.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('All Brands'),
                  leading: Radio<String>(
                    value: '',
                    groupValue: _selectedBrand,
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value!;
                      });
                      Navigator.pop(context);
                      _applyFilters();
                    },
                  ),
                );
              }
              final brand = brands[index - 1];
              final carCount = _cars.where((car) => car.brand == brand).length;
              return ListTile(
                title: Text('$brand ($carCount cars)'),
                leading: Radio<String>(
                  value: brand,
                  groupValue: _selectedBrand,
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value!;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _togglePriceFilter() {
    setState(() {
      _showPriceFilter = !_showPriceFilter;
    });
  }
}
