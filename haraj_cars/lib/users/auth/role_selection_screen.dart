import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // App Logo/Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Haraj Cars',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your account type',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Admin Option
                  _buildRoleCard(
                    context: context,
                    title: 'Admin',
                    subtitle: 'Login to manage cars, users, and system',
                    icon: Icons.admin_panel_settings,
                    color: Colors.red,
                    onTap: () => AppRouter.navigateToAdminLogin(context),
                  ),
                  
                  const SizedBox(height: 24),

                  // Worker Option
                  _buildRoleCard(
                    context: context,
                    title: 'Worker',
                    subtitle: 'Login to manage cars and assist customers',
                    icon: Icons.work_outline,
                    color: Colors.orange,
                    onTap: () => AppRouter.navigateToWorkerLogin(context),
                  ),
                  
                  const SizedBox(height: 24),

                  // Client Option
                  _buildRoleCard(
                    context: context,
                    title: 'Client',
                    subtitle: 'Browse cars and save favorites',
                    icon: Icons.person,
                    color: Colors.blue,
                    onTap: () => AppRouter.navigateToClientLogin(context),
                  ),
                  
                  const SizedBox(height: 40),

                  // Continue as Guest
                  TextButton(
                    onPressed: () => AppRouter.navigateToMain(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Continue as Guest',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Tajawal',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Debug Helper (only show in debug mode)
                  if (const bool.fromEnvironment('dart.vm.product') == false)
                    TextButton(
                      onPressed: () => AppRouter.navigateToWorkerDebug(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        'Worker Debug Helper',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.yellow.withOpacity(0.9),
                          fontFamily: 'Tajawal',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.black
                          : Colors.grey[800],
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.brightness == Brightness.dark
                          ? Colors.black87
                          : Colors.grey[600],
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
