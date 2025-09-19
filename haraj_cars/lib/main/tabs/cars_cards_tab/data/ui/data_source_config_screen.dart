// data_source_config_screen.dart - Screen for configuring data source

import 'package:flutter/material.dart';
import '../config/data_source_config.dart';
import '../di/data_source_factory.dart';

class DataSourceConfigScreen extends StatefulWidget {
  const DataSourceConfigScreen({Key? key}) : super(key: key);

  @override
  State<DataSourceConfigScreen> createState() => _DataSourceConfigScreenState();
}

class _DataSourceConfigScreenState extends State<DataSourceConfigScreen> {
  late DataSourceType _selectedDataSource;

  @override
  void initState() {
    super.initState();
    _selectedDataSource = DataSourceConfig.currentDataSource;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Source Configuration'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Data Source',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose your preferred data storage solution:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 24),
            
            // Supabase Option
            _buildDataSourceCard(
              title: 'Supabase',
              subtitle: 'Cloud PostgreSQL database with real-time features',
              icon: Icons.cloud,
              color: Colors.green,
              isSelected: _selectedDataSource == DataSourceType.supabase,
              onTap: () => _selectDataSource(DataSourceType.supabase),
            ),
            
            const SizedBox(height: 16),
            
            // Firebase Option (Coming Soon)
            _buildDataSourceCard(
              title: 'Firebase',
              subtitle: 'Google\'s cloud platform with Firestore database (Coming Soon)',
              icon: Icons.local_fire_department,
              color: Colors.grey,
              isSelected: false,
              onTap: () => _showComingSoonDialog('Firebase'),
            ),
            
            const SizedBox(height: 16),
            
            // SQLite Option (Coming Soon)
            _buildDataSourceCard(
              title: 'SQLite',
              subtitle: 'Local database stored on device (Coming Soon)',
              icon: Icons.storage,
              color: Colors.grey,
              isSelected: false,
              onTap: () => _showComingSoonDialog('SQLite'),
            ),
            
            const Spacer(),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveConfiguration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Configuration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSourceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : Colors.black,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDataSource(DataSourceType dataSource) {
    setState(() {
      _selectedDataSource = dataSource;
    });
  }

  void _saveConfiguration() {
    // Switch data source
    DataSourceFactory.switchDataSource(_selectedDataSource);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data source switched to ${DataSourceConfig.toTypeString(_selectedDataSource).toUpperCase()}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Navigate back
    Navigator.of(context).pop();
  }

  void _showComingSoonDialog(String dataSource) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$dataSource Coming Soon'),
          content: Text(
            'The $dataSource data source implementation is currently under development and will be available in a future update.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
