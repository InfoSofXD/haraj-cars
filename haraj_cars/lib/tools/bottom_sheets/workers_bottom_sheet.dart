import 'package:flutter/material.dart';
import '../../../tools/Palette/theme.dart' as custom_theme;
import '../../../supabase/supabase_service.dart';
import '../dialogs/delete_worker_dialog.dart';
import '../dialogs/edit_worker_dialog.dart';
import '../dialogs/add_worker_dialog.dart';
import 'modern_bottom_sheet_base.dart';

class WorkersBottomSheet extends StatefulWidget {
  const WorkersBottomSheet({Key? key}) : super(key: key);

  @override
  State<WorkersBottomSheet> createState() => _WorkersBottomSheetState();

  static void show(BuildContext context) {
    ModernBottomSheetBase.show(
      context,
      title: 'All Workers',
      icon: Icons.work,
      iconColor: Colors.orange,
      content: const WorkersBottomSheet(),
    );
  }
}

class _WorkersBottomSheetState extends State<WorkersBottomSheet> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _workers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workers = await _supabaseService.getAllWorkers();
      setState(() {
        _workers = workers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading workers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchWorkers(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Map<String, dynamic>> get _filteredWorkers {
    if (_searchQuery.isEmpty) return _workers;

    return _workers.where((worker) {
      final name = worker['name']?.toString().toLowerCase() ?? '';
      final email = worker['email']?.toString().toLowerCase() ?? '';
      final phone = worker['phone']?.toString().toLowerCase() ?? '';
      final searchQuery = _searchQuery.toLowerCase();

      return name.contains(searchQuery) ||
          email.contains(searchQuery) ||
          phone.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Worker count and add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_workers.length} registered workers',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'Tajawal',
              ),
            ),
            IconButton(
              onPressed: () => _showAddWorkerDialog(),
              icon: Icon(
                Icons.person_add,
                color: Colors.green,
                size: 24,
              ),
              tooltip: 'Add new worker',
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Search bar
        ModernBottomSheetSearchField(
          controller: _searchController,
          hintText: 'Search by name, email, or phone...',
          onChanged: () => _searchWorkers(_searchController.text),
          prefixIcon: Icons.search,
        ),

        const SizedBox(height: 20),

        // Workers list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                )
              : _filteredWorkers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No workers found'
                                : 'No workers match your search',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredWorkers.length,
                      itemBuilder: (context, index) {
                        final worker = _filteredWorkers[index];
                        return _buildWorkerCard(worker, isDark);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker, bool isDark) {
    final name = worker['name']?.toString() ?? 'Unknown';
    final email = worker['email']?.toString() ?? 'Unknown';
    final phone = worker['phone']?.toString() ?? 'Not provided';
    final permissions = worker['permissions'] as Map<String, dynamic>? ?? {};
    final createdAt = worker['created_at'];
    final lastSignIn = worker['last_sign_in'];

    DateTime? createdDate;
    DateTime? lastSignInDate;

    if (createdAt != null) {
      try {
        createdDate = DateTime.parse(createdAt.toString());
      } catch (e) {
        // Handle parsing error
      }
    }

    if (lastSignIn != null) {
      try {
        lastSignInDate = DateTime.parse(lastSignIn.toString());
      } catch (e) {
        // Handle parsing error
      }
    }

    // Count active permissions
    final activePermissions =
        permissions.values.where((value) => value == true).length;
    final totalPermissions = permissions.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.work,
              color: Colors.orange,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Worker info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Worker name
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : custom_theme.light.shade800,
                    fontFamily: 'Tajawal',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                    fontFamily: 'Tajawal',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Phone number
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Permissions summary
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.blue,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$activePermissions/$totalPermissions permissions',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (createdDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Joined ${_formatDate(createdDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                if (lastSignInDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.login,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Last seen ${_formatDate(lastSignInDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              // Edit button
              IconButton(
                onPressed: () => _showEditWorkerDialog(worker),
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue[400],
                  size: 20,
                ),
                tooltip: 'Edit worker',
              ),
              // View permissions button
              IconButton(
                onPressed: () => _showPermissionsDialog(worker),
                icon: Icon(
                  Icons.visibility,
                  color: Colors.orange[400],
                  size: 20,
                ),
                tooltip: 'View permissions',
              ),
              // Delete button
              IconButton(
                onPressed: () => _showDeleteWorkerDialog(worker),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 20,
                ),
                tooltip: 'Delete worker',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  void _showPermissionsDialog(Map<String, dynamic> worker) {
    final name = worker['name']?.toString() ?? 'Unknown';
    final permissions = worker['permissions'] as Map<String, dynamic>? ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            const SizedBox(width: 8),
            Text('$name\'s Permissions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: permissions.entries.map((entry) {
              final permission = entry.key;
              final isGranted = entry.value == true;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isGranted ? Icons.check_circle : Icons.cancel,
                      color: isGranted ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatPermissionName(permission),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isGranted ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatPermissionName(String permission) {
    switch (permission) {
      case 'add_car':
        return 'Add Cars';
      case 'use_scraper':
        return 'Use Scraper';
      case 'edit_car':
        return 'Edit Cars';
      case 'delete_car':
        return 'Delete Cars';
      case 'add_post':
        return 'Add Posts';
      case 'edit_post':
        return 'Edit Posts';
      case 'delete_post':
        return 'Delete Posts';
      case 'use_dashboard':
        return 'Use Dashboard';
      case 'delete_user':
        return 'Delete Users';
      default:
        return permission
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  void _showAddWorkerDialog() {
    showDialog(
      context: context,
      builder: (context) => AddWorkerDialog(
        onAdd: (workerData) => _addWorker(workerData),
      ),
    );
  }

  void _showEditWorkerDialog(Map<String, dynamic> worker) {
    showDialog(
      context: context,
      builder: (context) => EditWorkerDialog(
        worker: worker,
        onSave: (updatedData) => _updateWorker(worker['uuid'], updatedData),
      ),
    );
  }

  void _showDeleteWorkerDialog(Map<String, dynamic> worker) {
    final workerName = worker['name']?.toString() ?? 'Unknown';
    final workerEmail = worker['email']?.toString() ?? 'Unknown';
    final workerUuid = worker['uuid']?.toString() ?? '';

    DeleteWorkerDialog.show(
      context,
      workerName: workerName,
      workerEmail: workerEmail,
      onConfirm: () => _deleteWorker(workerUuid),
    );
  }

  Future<void> _addWorker(Map<String, dynamic> workerData) async {
    try {
      final success = await _supabaseService.addWorker(workerData);

      if (success) {
        // Reload workers list
        await _loadWorkers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Worker added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add worker. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding worker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateWorker(
      String workerUuid, Map<String, dynamic> updatedData) async {
    try {
      print(
          'WorkersBottomSheet: Updating worker $workerUuid with data: $updatedData');

      final success =
          await _supabaseService.updateWorker(workerUuid, updatedData);

      print('WorkersBottomSheet: Update result: $success');

      if (success) {
        // Reload workers list
        print('WorkersBottomSheet: Reloading workers list...');
        await _loadWorkers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Worker updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('WorkersBottomSheet: Update failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update worker. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('WorkersBottomSheet: Error updating worker: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating worker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteWorker(String workerUuid) async {
    try {
      final success = await _supabaseService.deleteWorker(workerUuid);

      if (success) {
        // Remove worker from local list
        setState(() {
          _workers.removeWhere((worker) => worker['uuid'] == workerUuid);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Worker deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete worker. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting worker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
