import 'package:flutter/material.dart';
import 'modern_dialog_base.dart';

class EditWorkerDialog extends StatefulWidget {
  final Map<String, dynamic> worker;
  final Function(Map<String, dynamic>) onSave;

  const EditWorkerDialog({
    Key? key,
    required this.worker,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditWorkerDialog> createState() => _EditWorkerDialogState();
}

class _EditWorkerDialogState extends State<EditWorkerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  late Map<String, bool> _permissions;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.worker['name'] ?? '');
    _emailController =
        TextEditingController(text: widget.worker['email'] ?? '');
    _phoneController =
        TextEditingController(text: widget.worker['phone'] ?? '');
    _passwordController = TextEditingController();

    // Initialize permissions
    final workerPermissions =
        widget.worker['permissions'] as Map<String, dynamic>? ?? {};
    _permissions = {
      'add_car': workerPermissions['add_car'] ?? false,
      'use_scraper': workerPermissions['use_scraper'] ?? false,
      'edit_car': workerPermissions['edit_car'] ?? false,
      'delete_car': workerPermissions['delete_car'] ?? false,
      'add_post': workerPermissions['add_post'] ?? false,
      'edit_post': workerPermissions['edit_post'] ?? false,
      'delete_post': workerPermissions['delete_post'] ?? false,
      'use_dashboard': workerPermissions['use_dashboard'] ?? false,
      'delete_user': workerPermissions['delete_user'] ?? false,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveWorker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedWorker = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'permissions': _permissions,
      };

      // Only include password if it's not empty
      if (_passwordController.text.isNotEmpty) {
        updatedWorker['password'] = _passwordController.text.trim();
      }

      widget.onSave(updatedWorker);
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ModernDialogBase(
      title: 'Edit Worker',
      icon: Icons.edit,
      iconColor: Colors.blue,
      width: 500,
      height: 600,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              _buildTextField(
                controller: _nameController,
                labelText: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter worker name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone field
              _buildTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              _buildTextField(
                controller: _passwordController,
                labelText: 'New Password (leave empty to keep current)',
                icon: Icons.lock,
                obscureText: true,
              ),

              const SizedBox(height: 24),

              // Permissions Section
              Text(
                'Permissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),

              // Permissions grid
              _buildPermissionsGrid(),
            ],
          ),
        ),
      ),
      actions: [
        ModernButton(
          text: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        ModernButton(
          text: 'Save Changes',
          isPrimary: true,
          icon: Icons.save,
          onPressed: _isLoading ? null : _saveWorker,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.grey[800]!.withOpacity(0.5),
                  Colors.grey[700]!.withOpacity(0.3),
                ]
              : [
                  Colors.white.withOpacity(0.8),
                  Colors.grey[50]!.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.grey[800],
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.blue,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsGrid() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]!.withOpacity(0.3) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          // Select All / Deselect All buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _permissions.updateAll((key, value) => true);
                    });
                  },
                  icon: const Icon(Icons.check_box, size: 16),
                  label: const Text('Select All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    foregroundColor: Colors.green,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _permissions.updateAll((key, value) => false);
                    });
                  },
                  icon: const Icon(Icons.check_box_outline_blank, size: 16),
                  label: const Text('Deselect All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Permissions grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: _permissions.entries.map((entry) {
              return _buildPermissionToggle(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle(String permission, bool isEnabled) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _permissions[permission] = !isEnabled;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.blue.withOpacity(0.1)
              : (isDark ? Colors.grey[700] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled
                ? Colors.blue
                : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isEnabled ? Icons.check_circle : Icons.cancel,
              color: isEnabled ? Colors.blue : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatPermissionName(permission),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isEnabled
                      ? Colors.blue[700]
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
}
