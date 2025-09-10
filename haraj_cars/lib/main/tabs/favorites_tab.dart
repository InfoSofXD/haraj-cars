import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/car.dart';
import '../../services/favorites_service.dart';
import '../../cards/car_card.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({Key? key}) : super(key: key);

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Car> _favoriteCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCars();
  }

  @override
  void didUpdateWidget(FavoritesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh favorites when tab becomes visible
    _loadFavoriteCars();
  }

  Future<void> _loadFavoriteCars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = await FavoritesService.getInstance();
      final favorites = await service.getFavoriteCars();
      setState(() {
        _favoriteCars = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFromFavorites(Car car) async {
    try {
      final service = await FavoritesService.getInstance();
      final success = await service.removeFromFavorites(car.carId);
      if (success) {
        setState(() {
          _favoriteCars.removeWhere((c) => c.carId == car.carId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove from favorites'),
              backgroundColor: Colors.red,
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Content (full screen, content scrolls under floating title)
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _favoriteCars.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadFavoriteCars,
                            child: _buildFavoritesList(),
                          ),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the heart icon on cars to add them to favorites',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingTitle() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            child: const Center(
              child: Text(
                'Your Favorites',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
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
            top: 100, // Space for floating title to hover above
            bottom: 110, // Space for floating bottom nav bar
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _favoriteCars.length,
          itemBuilder: (context, index) {
            final car = _favoriteCars[index];
            return CarCard(
              car: car,
              isFavorite: true,
              onToggleFavorite: () => _removeFromFavorites(car),
            );
          },
        );
      },
    );
  }
}
