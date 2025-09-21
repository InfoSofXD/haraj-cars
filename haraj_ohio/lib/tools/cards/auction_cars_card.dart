import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/car.dart';
import '../../tools/Palette/theme.dart' as custom_theme;

class AuctionCarsCard extends StatefulWidget {
  final List<Car> cars;
  final Set<String> favoriteCarIds;
  final bool isAdmin;
  final Function(Car) onTap;
  final Function(Car) onToggleFavorite;
  final Function(Car) onEdit;
  final Function(Car) onDelete;
  final Function(Car) onStatusUpdate;

  const AuctionCarsCard({
    Key? key,
    required this.cars,
    required this.favoriteCarIds,
    required this.isAdmin,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  State<AuctionCarsCard> createState() => _AuctionCarsCardState();
}

class _AuctionCarsCardState extends State<AuctionCarsCard> {
  late PageController _pageController;
  int _currentPage = 0;
  int _cardsPerPage = 3;
  double _cardWidth = 180;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCardDimensions();
    });
  }

  void _calculateCardDimensions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 32.0; // Account for screen padding
    final availableWidth = screenWidth - horizontalPadding;

    // Always show 3 cards per page, just adjust card width
    _cardsPerPage = 3;
    _cardWidth = ((availableWidth - 60) / 3).clamp(120.0, 200.0);

    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _getMaxPage()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int _getMaxPage() {
    return ((widget.cars.length - 1) / _cardsPerPage).floor();
  }

  List<Car> _getCurrentPageCars() {
    final startIndex = _currentPage * _cardsPerPage;
    final endIndex = (startIndex + _cardsPerPage).clamp(0, widget.cars.length);
    return widget.cars.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.cars.isEmpty) {
      return const SizedBox.shrink();
    }

    // Recalculate dimensions if screen size changed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCardDimensions();
    });

    return SizedBox(
      height: 200, // Fixed height
      child: Stack(
        children: [
          // Cards Container
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _getMaxPage() + 1,
            itemBuilder: (context, pageIndex) {
              final pageCars = _getPageCars(pageIndex);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    pageCars.map((car) => _buildCarCard(car, theme)).toList(),
              );
            },
          ),

          // Left Arrow - Hovering over the list
          if (_currentPage > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildArrowButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _previousPage,
                  theme: theme,
                ),
              ),
            ),

          // Right Arrow - Hovering over the list
          if (_currentPage < _getMaxPage())
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildArrowButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: _nextPage,
                  theme: theme,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Car> _getPageCars(int pageIndex) {
    final startIndex = pageIndex * _cardsPerPage;
    final endIndex = (startIndex + _cardsPerPage).clamp(0, widget.cars.length);
    return widget.cars.sublist(startIndex, endIndex);
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : custom_theme.light.shade100.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.2)
                    : custom_theme.light.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : custom_theme.light.shade800,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard(Car car, ThemeData theme) {
    return Container(
      width: _cardWidth, // Dynamic width based on screen size
      height: 180, // Fixed height
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Car Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
              ),
              child: car.mainImage != null && car.mainImage!.isNotEmpty
                  ? Image.network(
                      car.mainImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.directions_car,
                          size: 50,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.5)
                              : custom_theme.light.shade600,
                        );
                      },
                    )
                  : Icon(
                      Icons.directions_car,
                      size: 50,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.5)
                          : custom_theme.light.shade600,
                    ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Car Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      car.computedTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${car.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    Text(
                      '${car.year} • ${car.mileage.toStringAsFixed(0)}k miles',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Favorite Button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => widget.onToggleFavorite(car),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: widget.favoriteCarIds.contains(car.carId)
                        ? Colors.red.withOpacity(0.35)
                        : Colors.grey.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.favoriteCarIds.contains(car.carId)
                          ? Colors.red
                          : Colors.white,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    widget.favoriteCarIds.contains(car.carId)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                    color: widget.favoriteCarIds.contains(car.carId)
                        ? Colors.red
                        : Colors.white,
                  ),
                ),
              ),
            ),

            // Tap Gesture
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onTap(car),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
