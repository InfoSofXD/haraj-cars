import 'package:flutter/material.dart';
import 'side_bar_of_dashaboard/admin_worker_sidebar.dart';
import 'dashboard_tab.dart';
import 'workers_management_screen.dart';
import '../../../main/tabs/cars_cards_tab/cars_main_search_page.dart';
import '../user_management_screen.dart';
import '../../../features/logger/presentation/pages/logs_page.dart';
import '../../../features/logger/data/providers/logger_provider.dart';

class AdminDashboardLayout extends StatefulWidget {
  const AdminDashboardLayout({Key? key}) : super(key: key);

  @override
  State<AdminDashboardLayout> createState() => _AdminDashboardLayoutState();
}

class _AdminDashboardLayoutState extends State<AdminDashboardLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? colorScheme.background
          : Colors.grey[50],
      body: Row(
        children: [
          // Sidebar
          AdminWorkerSidebar(
            selectedIndex: _selectedIndex,
            onNavigateToTab: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildCarsManagementContent();
      case 2:
        return _buildWorkersManagementContent();
      case 3:
        return _buildClientsManagementContent();
      case 4:
        return _buildAnalyticsContent();
      case 5:
        return _buildLogsContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return DashboardTab(
      onNavigateToTab: (index) {
        // Handle navigation within dashboard if needed
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget _buildCarsManagementContent() {
    return CarsTab(
      isAdmin: true,
      onEditCar: (car) {
        // Handle edit car
        _showEditCarDialog(car);
      },
      onDeleteCar: (car) {
        // Handle delete car
        _showDeleteCarDialog(car);
      },
      onShowCarDetails: (car) {
        // Handle show car details
        _showCarDetails(car);
      },
      onShowStatusUpdate: (car) {
        // Handle status update
        _showStatusUpdateDialog(car);
      },
    );
  }

  Widget _buildWorkersManagementContent() {
    return const WorkersManagementScreen();
  }

  Widget _buildClientsManagementContent() {
    return const UserManagementScreen();
  }

  Widget _buildAnalyticsContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'View reports, insights, and analytics for your car marketplace.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          // Placeholder for analytics content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Analytics Coming Soon',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This section will contain detailed analytics and reports.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsContent() {
    return LogsPage(
      loggerService: LoggerProvider.instance,
    );
  }

  // Placeholder methods for car management actions
  void _showEditCarDialog(car) {
    // TODO: Implement edit car dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit car functionality coming soon!')),
    );
  }

  void _showDeleteCarDialog(car) {
    // TODO: Implement delete car dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete car functionality coming soon!')),
    );
  }

  void _showCarDetails(car) {
    // TODO: Implement show car details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Car details functionality coming soon!')),
    );
  }

  void _showStatusUpdateDialog(car) {
    // TODO: Implement status update dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status update functionality coming soon!')),
    );
  }
}
