import 'package:flutter/material.dart';
import '../tools/Palette/theme.dart';
import '../tools/Palette/gradients.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Welcome to Haraj Ohio",
      description:
          "Your ultimate destination for buying and selling cars in Ohio. Find your dream car or sell your current one with ease.",
      icon: Icons.directions_car,
      color: light[500]!,
    ),
    OnboardingPage(
      title: "Browse Thousands of Cars",
      description:
          "Explore our extensive collection of cars from various brands, models, and price ranges. Filter by your preferences to find exactly what you're looking for.",
      icon: Icons.search,
      color: light[400]!,
    ),
    OnboardingPage(
      title: "Global Car Market",
      description:
          "Access car listings from multiple global sites and compare prices. Get the best deals from trusted sellers worldwide.",
      icon: Icons.public,
      color: light[600]!,
    ),
    OnboardingPage(
      title: "Save Your Favorites",
      description:
          "Create your personal collection of favorite cars. Save cars you love and easily access them later for comparison.",
      icon: Icons.favorite,
      color: light[300]!,
    ),
    OnboardingPage(
      title: "Trusted & Secure",
      description:
          "All our sellers are verified and trusted. Your safety and satisfaction are our top priorities. Start your car buying journey today!",
      icon: Icons.security,
      color: light[700]!,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
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

  void _goToLogin() {
    // Navigate to sign manager
    Navigator.of(context).pushNamed('/sign_manager');
  }

  void _goToGuest() {
    // Navigate to tab manager screen
    Navigator.of(context).pushReplacementNamed('/tab_manger');
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isLight ? LightGradient.main : DarkGradient.main,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _goToGuest,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index]);
                  },
                ),
              ),

              // Bottom section with navigation
              _buildBottomSection(isLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool isLight) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          if (_currentPage < _pages.length - 1) ...[
            // Next button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isLight ? light[500] : dark[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Previous button (if not on first page)
            if (_currentPage > 0)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
          ] else ...[
            // Final page - Login and Guest buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _goToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isLight ? light[500] : dark[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _goToGuest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
