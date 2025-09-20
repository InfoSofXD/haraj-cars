import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/car.dart';
import '../../tools/Palette/theme.dart' as custom_theme;
import '../tools/dialogs/dialogs.dart';

class FilterPage extends StatefulWidget {
  final List<Car> cars;
  final String selectedBrand;
  final String selectedYear;
  final String selectedCondition;
  final int selectedStatus;
  final RangeValues priceRange;
  final RangeValues customConditionRange;
  final RangeValues likeNewRange;
  final RangeValues goodRange;
  final RangeValues fairRange;
  final RangeValues highMileageRange;
  final double minPrice;
  final double maxPrice;
  final double minMileage;
  final double maxMileage;
  final Function(String, String, String, int, RangeValues, RangeValues,
      RangeValues, RangeValues, RangeValues, RangeValues) onFiltersApplied;

  const FilterPage({
    Key? key,
    required this.cars,
    required this.selectedBrand,
    required this.selectedYear,
    required this.selectedCondition,
    required this.selectedStatus,
    required this.priceRange,
    required this.customConditionRange,
    required this.likeNewRange,
    required this.goodRange,
    required this.fairRange,
    required this.highMileageRange,
    required this.minPrice,
    required this.maxPrice,
    required this.minMileage,
    required this.maxMileage,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late String _selectedBrand;
  late String _selectedYear;
  late String _selectedCondition;
  late int _selectedStatus;
  late RangeValues _priceRange;
  late RangeValues _customConditionRange;
  late RangeValues _likeNewRange;
  late RangeValues _goodRange;
  late RangeValues _fairRange;
  late RangeValues _highMileageRange;
  bool _showPriceFilter = false;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.selectedBrand;
    _selectedYear = widget.selectedYear;
    _selectedCondition = widget.selectedCondition;
    _selectedStatus = widget.selectedStatus;
    _priceRange = widget.priceRange;
    _customConditionRange = widget.customConditionRange;
    _likeNewRange = widget.likeNewRange;
    _goodRange = widget.goodRange;
    _fairRange = widget.fairRange;
    _highMileageRange = widget.highMileageRange;
  }

  void _applyFilters() {
    widget.onFiltersApplied(
      _selectedBrand,
      _selectedYear,
      _selectedCondition,
      _selectedStatus,
      _priceRange,
      _customConditionRange,
      _likeNewRange,
      _goodRange,
      _fairRange,
      _highMileageRange,
    );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedBrand = '';
      _selectedYear = '';
      _selectedCondition = '';
      _selectedStatus = 0;
      _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
      _customConditionRange = RangeValues(widget.minMileage, widget.maxMileage);
      _likeNewRange = const RangeValues(0, 30000);
      _goodRange = const RangeValues(30000, 60000);
      _fairRange = const RangeValues(60000, 100000);
      _highMileageRange = const RangeValues(100000, 500000);
      _showPriceFilter = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? colorScheme.background
          : Colors.white,
      appBar: AppBar(
        title: Text(
          'Filters',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.brightness == Brightness.dark
            ? colorScheme.surface
            : Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: colorScheme.primary,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Condition Filter
            _buildFilterSection(
              title: 'Condition',
              icon: Icons.new_releases,
              child: _buildConditionFilter(),
            ),

            const SizedBox(height: 24),

            // Year Filter
            _buildFilterSection(
              title: 'Year',
              icon: Icons.calendar_today,
              child: _buildYearFilter(),
            ),

            const SizedBox(height: 24),

            // Brand Filter
            _buildFilterSection(
              title: 'Brand',
              icon: Icons.directions_car,
              child: _buildBrandFilter(),
            ),

            const SizedBox(height: 24),

            // Status Filter
            _buildFilterSection(
              title: 'Status',
              icon: Icons.info,
              child: _buildStatusFilter(),
            ),

            const SizedBox(height: 24),

            // Price Filter
            _buildFilterSection(
              title: 'Price Range',
              icon: Icons.local_offer,
              child: _buildPriceFilter(),
            ),

            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[800]!.withOpacity(0.3)
            : custom_theme.light.shade100.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : custom_theme.light.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : custom_theme.light.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : custom_theme.light.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildConditionFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedCondition.isNotEmpty;

    return GestureDetector(
      onTap: () => _showConditionFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCondition.isEmpty
                  ? 'All Conditions'
                  : _selectedCondition == 'custom-range'
                      ? 'Custom Range'
                      : _getConditionDisplayText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
                color: isSelected
                    ? Colors.white
                    : theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.8)
                        : custom_theme.light.shade700,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isSelected
                  ? Colors.white
                  : theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.8)
                      : custom_theme.light.shade700,
            ),
          ],
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedYear.isEmpty ? 'All Years' : _selectedYear,
              style: TextStyle(
                fontSize: 14,
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
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isSelected
                  ? (theme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white)
                  : theme.brightness == Brightness.dark
                      ? Colors.white
                      : custom_theme.light.shade700,
            ),
          ],
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedBrand.isEmpty ? 'All Brands' : _selectedBrand,
              style: TextStyle(
                fontSize: 14,
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
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isSelected
                  ? (theme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white)
                  : theme.brightness == Brightness.dark
                      ? Colors.white
                      : custom_theme.light.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedStatus != 0;

    String statusText = 'All Status';
    if (_selectedStatus == 1) {
      statusText = 'Available';
    } else if (_selectedStatus == 2) {
      statusText = 'Unavailable';
    } else if (_selectedStatus == 3) {
      statusText = 'Auction';
    } else if (_selectedStatus == 4) {
      statusText = 'Sold';
    }

    return GestureDetector(
      onTap: () => _showStatusFilter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statusText,
              style: TextStyle(
                fontSize: 14,
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
            ),
            Icon(
              Icons.arrow_drop_down,
              color: isSelected
                  ? (theme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white)
                  : theme.brightness == Brightness.dark
                      ? Colors.white
                      : custom_theme.light.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDefaultRange = _priceRange.start == widget.minPrice &&
        _priceRange.end == widget.maxPrice;
    final isSelected = !isDefaultRange;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showPriceFilter = !_showPriceFilter;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDefaultRange
                      ? 'All Prices'
                      : '\$${_priceRange.start.round()}-\$${_priceRange.end.round()}',
                  style: TextStyle(
                    fontSize: 14,
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
                ),
                Icon(
                  _showPriceFilter
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isSelected
                      ? (theme.brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white)
                      : theme.brightness == Brightness.dark
                          ? Colors.white
                          : custom_theme.light.shade700,
                ),
              ],
            ),
          ),
        ),
        if (_showPriceFilter) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : custom_theme.light.shade200.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : custom_theme.light.shade400,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : custom_theme.light.shade800,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  values: _priceRange,
                  min: widget.minPrice,
                  max: widget.maxPrice,
                  divisions: (widget.maxPrice - widget.minPrice).round() > 0
                      ? (widget.maxPrice - widget.minPrice).round()
                      : 1,
                  labels: RangeLabels(
                    '\$${_priceRange.start.round()}',
                    '\$${_priceRange.end.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                Text(
                  'Range: \$${widget.minPrice.round()} - \$${widget.maxPrice.round()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : custom_theme.light.shade600,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
      default:
        return _selectedCondition.replaceAll('-', ' ').toUpperCase();
    }
  }

  void _showConditionFilter() {
    showDialog(
      context: context,
      builder: (context) => ConditionFilterDialog(
        cars: widget.cars,
        selectedCondition: _selectedCondition,
        onConditionSelected: (value, rangeValues) {
          setState(() {
            _selectedCondition = value;
            if (value == 'custom-range') {
              if (rangeValues != null) {
                _customConditionRange = rangeValues;
              } else {
                _customConditionRange =
                    RangeValues(widget.minMileage, widget.maxMileage);
              }
            }
          });
        },
      ),
    );
  }

  void _showYearFilter() {
    YearFilterDialog.show(
      context,
      cars: widget.cars,
      selectedYear: _selectedYear,
      onYearSelected: (value) {
        setState(() {
          _selectedYear = value;
        });
      },
    );
  }

  void _showBrandFilter() {
    BrandFilterDialog.show(
      context,
      cars: widget.cars,
      selectedBrand: _selectedBrand,
      onBrandSelected: (value) {
        setState(() {
          _selectedBrand = value;
        });
      },
    );
  }

  void _showStatusFilter() {
    StatusFilterDialog.show(
      context,
      cars: widget.cars,
      selectedStatus: _selectedStatus,
      onStatusSelected: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
    );
  }
}
