import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/tabs/sing_in_tab.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final supabase = Supabase.instance.client;
    _user = supabase.auth.currentUser;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
              // Content (full screen, content scrolls under floating title)
              Expanded(
                child: SingleChildScrollView(
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

                      // Profile Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFBBDEFB),
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
                            // Profile Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFBBDEFB),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: const Color(0xFF1976D2),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // User Name
                            Text(
                              _user?.userMetadata?['full_name'] ?? 'Guest User',
                              style: const TextStyle(
                                color: Color(0xFF0D47A1),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            // User Email
                            Text(
                              _user?.email ?? 'No email',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontFamily: 'Tajawal',
                              ),
                              textAlign: TextAlign.center,
                            ),

                            if (_user?.userMetadata?['phone'] != null) ...[
                              const SizedBox(height: 8),

                              // User Phone
                              Text(
                                _user!.userMetadata!['phone'],
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Account Options
                      if (_user != null) ...[
                        // My Listings
                        _buildAccountOption(
                          icon: Icons.directions_car,
                          title: 'My Listings',
                          subtitle: 'View your car listings',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('My Listings feature coming soon!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Favorites
                        _buildAccountOption(
                          icon: Icons.favorite,
                          title: 'My Favorites',
                          subtitle: 'View your favorite cars',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Favorites feature coming soon!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Settings
                        _buildAccountOption(
                          icon: Icons.settings,
                          title: 'Settings',
                          subtitle: 'App preferences and settings',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings feature coming soon!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Help & Support
                        _buildAccountOption(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get help and contact support',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Help & Support feature coming soon!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Sign Out Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _signOut,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 8,
                              shadowColor:
                                  const Color(0xFFD32F2F).withOpacity(0.3),
                            ),
                            child: const Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Guest User Options
                        _buildAccountOption(
                          icon: Icons.login,
                          title: 'Sign In',
                          subtitle: 'Sign in to your account',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      _buildAccountOption(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Help & Support feature coming soon!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
                'My Account',
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

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFBBDEFB),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Color(0xFF1976D2),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
