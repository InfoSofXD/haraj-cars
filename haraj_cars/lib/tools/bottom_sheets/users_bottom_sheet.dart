import 'package:flutter/material.dart';
import '../../../tools/Palette/theme.dart' as custom_theme;
import '../../../supabase/supabase_service.dart';
import '../dialogs/delete_user_dialog.dart';
import 'modern_bottom_sheet_base.dart';

class UsersBottomSheet extends StatefulWidget {
  const UsersBottomSheet({Key? key}) : super(key: key);

  @override
  State<UsersBottomSheet> createState() => _UsersBottomSheetState();

  static void show(BuildContext context) {
    ModernBottomSheetBase.show(
      context,
      title: 'All Users',
      icon: Icons.people,
      iconColor: custom_theme.light.shade700,
      content: const UsersBottomSheet(),
    );
  }
}

class _UsersBottomSheetState extends State<UsersBottomSheet> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _supabaseService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchUsers(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;

    return _users.where((user) {
      final email = user['email']?.toString().toLowerCase() ?? '';
      final fullName = user['full_name']?.toString().toLowerCase() ?? '';
      final phone = user['phone']?.toString().toLowerCase() ?? '';
      final searchQuery = _searchQuery.toLowerCase();

      return email.contains(searchQuery) ||
          fullName.contains(searchQuery) ||
          phone.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // User count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_users.length} registered users',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Search bar
        ModernBottomSheetSearchField(
          controller: _searchController,
          hintText: 'Search by name, email, or phone...',
          onChanged: () => _searchUsers(_searchController.text),
          prefixIcon: Icons.search,
        ),

        const SizedBox(height: 20),

        // Users list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: custom_theme.light.shade700,
                  ),
                )
              : _filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No users found'
                                : 'No users match your search',
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
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserCard(user, isDark);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isDark) {
    final email = user['email']?.toString() ?? 'Unknown';
    final createdAt = user['created_at'];
    final lastSignIn = user['last_sign_in'];
    final emailConfirmed = user['email_confirmed'] ?? false;

    // Get real name and phone from metadata
    final fullName = user['full_name']?.toString() ?? 'Not provided';
    final phoneNumber = user['phone']?.toString() ?? 'Not provided';

    // Use full name if available, otherwise extract from email
    final displayName = fullName != 'Not provided'
        ? fullName
        : (email.split('@').isNotEmpty ? email.split('@')[0] : 'User');

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
              color: custom_theme.light.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.person,
              color: custom_theme.light.shade700,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name
                Text(
                  displayName,
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
                      phoneNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (emailConfirmed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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

          // Delete button
          IconButton(
            onPressed: () => _showDeleteUserDialog(user),
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red[400],
              size: 20,
            ),
            tooltip: 'Delete user',
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

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    final userName = user['full_name']?.toString() ?? 'Unknown';
    final userEmail = user['email']?.toString() ?? 'Unknown';
    final userId = user['id']?.toString() ?? '';

    DeleteUserDialog.show(
      context,
      userName: userName,
      userEmail: userEmail,
      onConfirm: () => _deleteUser(userId),
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      final success = await _supabaseService.deleteUser(userId);

      if (success) {
        // Remove user from local list
        setState(() {
          _users.removeWhere((user) => user['id'] == userId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete user. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
