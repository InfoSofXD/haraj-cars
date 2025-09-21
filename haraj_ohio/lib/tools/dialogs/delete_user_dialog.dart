import 'package:flutter/material.dart';
import 'dart:math';
import '../../../tools/Palette/theme.dart' as custom_theme;
import 'modern_dialog_base.dart';

class DeleteUserDialog extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onConfirm;

  const DeleteUserDialog({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.onConfirm,
  }) : super(key: key);

  static Future<bool?> show(
    BuildContext context, {
    required String userName,
    required String userEmail,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteUserDialog(
        userName: userName,
        userEmail: userEmail,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  late String _confirmationCode;
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeValid = false;

  @override
  void initState() {
    super.initState();
    _generateConfirmationCode();
    _codeController.addListener(_validateCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _generateConfirmationCode() {
    final random = Random();
    _confirmationCode = (1000 + random.nextInt(9000)).toString();
  }

  void _validateCode() {
    setState(() {
      _isCodeValid = _codeController.text == _confirmationCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ModernDialogBase(
      title: 'Delete User Account',
      icon: Icons.person_remove,
      iconColor: Colors.red,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Warning message
          Text(
            'Are you sure you want to delete this user account?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : custom_theme.light.shade800,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // User details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white
                              : custom_theme.light.shade800,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.userEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'Tajawal',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Confirmation code section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.blue[900]?.withOpacity(0.2) : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.blue[400]! : Colors.blue[200]!,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 16,
                      color: isDark ? Colors.blue[300] : Colors.blue[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Confirmation Required',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.blue[300] : Colors.blue[700],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'To confirm deletion, please enter this code:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Confirmation code display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? Colors.blue[400]! : Colors.blue[300]!,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _confirmationCode,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.blue[300] : Colors.blue[700],
                      fontFamily: 'Tajawal',
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Input field
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : custom_theme.light.shade800,
                    fontFamily: 'Tajawal',
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      fontFamily: 'Tajawal',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _isCodeValid ? Colors.green : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: _isCodeValid ? Colors.green : Colors.blue,
                        width: 2,
                      ),
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Warning text
          Text(
            'This action cannot be undone. The user will lose access to their account and all associated data.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.red[300] : Colors.red[600],
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Delete button
        ElevatedButton(
          onPressed: _isCodeValid
              ? () {
                  Navigator.of(context).pop(true);
                  widget.onConfirm();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isCodeValid ? Colors.red : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete, size: 16),
              const SizedBox(width: 4),
              Text(
                'Delete User',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
