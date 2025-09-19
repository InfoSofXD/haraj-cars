import 'package:flutter/material.dart';

class AuthComponents {
  static Widget buildAuthCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32.0),
        child: child,
      ),
    );
  }

  static Widget buildAuthIcon({
    required IconData icon,
    required Color color,
    double size = 48,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  static Widget buildAuthTitle({
    required String title,
    required String subtitle,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : colorScheme.onSurface,
            fontFamily: 'Tajawal',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey[600],
            fontFamily: 'Tajawal',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget buildAuthTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
    );
  }

  static Widget buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
    );
  }

  static Widget buildAuthButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
    );
  }

  static Widget buildAuthLink({
    required String text,
    required String linkText,
    required VoidCallback onPressed,
    required Color linkColor,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey[600],
            fontFamily: 'Tajawal',
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            linkText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: linkColor,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildGuestButton({
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      child: Text(
        'Continue as Guest',
        style: TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white70
              : Colors.grey[600],
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  static Widget buildAuthBackground({
    required BuildContext context,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
            child: child,
          ),
        ),
      ),
    );
  }
}
