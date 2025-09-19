import 'package:flutter/material.dart';
import '../data/worker_model.dart';

class WorkerCreateEditPage extends StatefulWidget {
  final Worker? worker; // null for create, Worker object for edit
  final Function(Worker)? onSave;

  const WorkerCreateEditPage({
    Key? key,
    this.worker,
    this.onSave,
  }) : super(key: key);

  @override
  State<WorkerCreateEditPage> createState() => _WorkerCreateEditPageState();
}

class _WorkerCreateEditPageState extends State<WorkerCreateEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();

  String _selectedPosition = 'Sales Representative';
  bool _isActive = true;
  List<String> _selectedPermissions = ['view_cars', 'add_cars'];

  final List<String> _positions = [
    'Sales Representative',
    'Marketing Specialist',
    'Customer Service',
    'Data Entry Clerk',
    'Manager',
    'Supervisor',
  ];

  final List<String> _availablePermissions = [
    'view_cars',
    'add_cars',
    'edit_cars',
    'delete_cars',
    'view_users',
    'manage_users',
    'view_reports',
    'manage_settings',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.worker != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final worker = widget.worker!;
    _nameController.text = worker.name;
    _emailController.text = worker.email;
    _phoneController.text = worker.phone;
    _positionController.text = worker.position;
    _selectedPosition = worker.position;
    _isActive = worker.isActive;
    _selectedPermissions = List.from(worker.permissions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _saveWorker() {
    if (!_formKey.currentState!.validate()) return;

    final worker = Worker(
      id: widget.worker?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      position: _selectedPosition,
      joinDate: widget.worker?.joinDate ?? DateTime.now(),
      isActive: _isActive,
      permissions: _selectedPermissions,
    );

    widget.onSave?.call(worker);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEdit = widget.worker != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Worker' : 'Create Worker'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit : Icons.person_add,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit ? 'Edit Worker Details' : 'Create New Worker',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                isEdit 
                                    ? 'Update worker information and permissions'
                                    : 'Add a new worker to your team',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Personal Information Section
                    _buildSectionHeader('Personal Information', Icons.person),
                    const SizedBox(height: 16),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter worker name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email address';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Work Information Section
                    _buildSectionHeader('Work Information', Icons.work),
                    const SizedBox(height: 16),

                    // Position Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      decoration: InputDecoration(
                        labelText: 'Position',
                        prefixIcon: const Icon(Icons.work_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      items: _positions.map((position) {
                        return DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPosition = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Active Status Switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.toggle_on,
                            color: _isActive ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  _isActive ? 'Worker is active' : 'Worker is inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Permissions Section
                    _buildSectionHeader('Permissions', Icons.security),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Permissions',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availablePermissions.map((permission) {
                              final isSelected = _selectedPermissions.contains(permission);
                              return FilterChip(
                                label: Text(_getPermissionDisplayName(permission)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedPermissions.add(permission);
                                    } else {
                                      _selectedPermissions.remove(permission);
                                    }
                                  });
                                },
                                selectedColor: Colors.blue.withOpacity(0.2),
                                checkmarkColor: Colors.blue,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveWorker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(isEdit ? 'Update Worker' : 'Create Worker'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getPermissionDisplayName(String permission) {
    switch (permission) {
      case 'view_cars':
        return 'View Cars';
      case 'add_cars':
        return 'Add Cars';
      case 'edit_cars':
        return 'Edit Cars';
      case 'delete_cars':
        return 'Delete Cars';
      case 'view_users':
        return 'View Users';
      case 'manage_users':
        return 'Manage Users';
      case 'view_reports':
        return 'View Reports';
      case 'manage_settings':
        return 'Manage Settings';
      default:
        return permission;
    }
  }
}
