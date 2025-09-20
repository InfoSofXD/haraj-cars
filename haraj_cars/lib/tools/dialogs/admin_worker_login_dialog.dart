import 'package:flutter/material.dart';
import '../../supabase/supabase_service.dart';
import 'modern_dialog_base.dart';

enum LoginType { admin, worker }

class AdminWorkerLoginDialog extends StatefulWidget {
  final Function(bool, {LoginType? loginType, Map<String, dynamic>? userData})
      onLoginResult;

  const AdminWorkerLoginDialog({
    Key? key,
    required this.onLoginResult,
  }) : super(key: key);

  @override
  State<AdminWorkerLoginDialog> createState() => _AdminWorkerLoginDialogState();
}

class _AdminWorkerLoginDialogState extends State<AdminWorkerLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  LoginType _loginType = LoginType.admin;

  @override
  void initState() {
    super.initState();
    _updateDefaultCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateDefaultCredentials() {
    if (_loginType == LoginType.admin) {
      _usernameController.text = 'admin@harajcars.com';
      _passwordController.text = 'admin123';
    } else {
      _usernameController.text = 'ahmed@harajcars.com';
      _passwordController.text = 'worker123';
    }
  }

  void _onLoginTypeChanged(LoginType? newType) {
    if (newType != null && newType != _loginType) {
      setState(() {
        _loginType = newType;
        _updateDefaultCredentials();
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = SupabaseService();
      bool success = false;
      Map<String, dynamic>? userData;

      if (_loginType == LoginType.admin) {
        // Admin login
        await supabaseService.testAdminTable();
        print(
            'Attempting admin login with email: ${_usernameController.text.trim()}');
        userData = await supabaseService.authenticateAdmin(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
        success = userData != null;
        print('Admin login result: $success');
      } else {
        // Worker login
        print(
            'Attempting worker login with email: ${_usernameController.text.trim()}');
        userData = await supabaseService.authenticateWorker(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
        success = userData != null;
        print('Worker login result: $success');
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onLoginResult(success,
            loginType: _loginType, userData: userData);

        if (success) {
          final userType = _loginType == LoginType.admin ? 'Admin' : 'Worker';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userType login successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid credentials'),
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
      title: _loginType == LoginType.admin ? 'Admin Login' : 'Worker Login',
      icon: _loginType == LoginType.admin
          ? Icons.admin_panel_settings
          : Icons.work,
      iconColor: _loginType == LoginType.admin
          ? (isDark ? Colors.white : theme.colorScheme.primary)
          : Colors.orange,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Login Type Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[800]!.withOpacity(0.5)
                    : Colors.grey[200]!.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      'Admin',
                      LoginType.admin,
                      Icons.admin_panel_settings,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildToggleButton(
                      'Worker',
                      LoginType.worker,
                      Icons.work,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Email field
            _buildModernTextField(
              controller: _usernameController,
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
            const SizedBox(height: 20),
            // Password field
            _buildModernTextField(
              controller: _passwordController,
              labelText: 'Password',
              icon: Icons.lock,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Default credentials hint
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _loginType == LoginType.admin
                      ? [
                          Colors.blue.withOpacity(0.1),
                          Colors.blue.withOpacity(0.05),
                        ]
                      : [
                          Colors.orange.withOpacity(0.1),
                          Colors.orange.withOpacity(0.05),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _loginType == LoginType.admin
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _loginType == LoginType.admin
                        ? Colors.blue
                        : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _loginType == LoginType.admin
                          ? 'Default credentials: admin@harajcars.com / admin123'
                          : 'Default credentials: ahmed@harajcars.com / worker123',
                      style: TextStyle(
                        color: _loginType == LoginType.admin
                            ? Colors.blue[700]
                            : Colors.orange[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ModernButton(
          text: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        ModernButton(
          text: 'Login',
          isPrimary: true,
          icon: Icons.login,
          onPressed: _isLoading ? null : _login,
          width: 120,
        ),
      ],
    );
  }

  Widget _buildToggleButton(String text, LoginType type, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _loginType == type;

    return GestureDetector(
      onTap: () => _onLoginTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (type == LoginType.admin
                  ? theme.colorScheme.primary
                  : Colors.orange)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

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
            color: isDark ? Colors.white : colorScheme.primary,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// Backward compatibility - keep the old class name
class AdminLoginDialog extends AdminWorkerLoginDialog {
  AdminLoginDialog({
    Key? key,
    required Function(bool) onLoginResult,
  }) : super(
          key: key,
          onLoginResult: (success, {loginType, userData}) =>
              onLoginResult(success),
        );
}
