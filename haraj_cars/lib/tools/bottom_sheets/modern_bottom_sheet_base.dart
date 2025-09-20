import 'package:flutter/material.dart';
import 'dart:ui';

class ModernBottomSheetBase extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;
  final double? height;
  final bool showHandle;
  final bool isScrollControlled;
  final EdgeInsets? padding;

  const ModernBottomSheetBase({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
    this.icon,
    this.iconColor,
    this.height,
    this.showHandle = true,
    this.isScrollControlled = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: height ?? screenHeight * 0.85,
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.95,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        Colors.grey[800]!.withOpacity(0.95),
                        Colors.grey[900]!.withOpacity(0.98),
                      ]
                    : [
                        Colors.white.withOpacity(0.98),
                        Colors.grey[50]!.withOpacity(0.95),
                      ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                if (showHandle)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              colorScheme.primary.withOpacity(0.1),
                              colorScheme.secondary.withOpacity(0.05),
                            ]
                          : [
                              colorScheme.primary.withOpacity(0.05),
                              colorScheme.secondary.withOpacity(0.02),
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (iconColor ?? colorScheme.primary)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[800],
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.grey[700]!.withOpacity(0.5)
                              : Colors.grey[200]!.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: Padding(
                    padding: padding ?? const EdgeInsets.all(24),
                    child: content,
                  ),
                ),

                // Actions
                if (actions != null && actions!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!
                          .map((action) => Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: action,
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
    IconData? icon,
    Color? iconColor,
    double? height,
    bool showHandle = true,
    bool isScrollControlled = true,
    EdgeInsets? padding,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernBottomSheetBase(
        title: title,
        content: content,
        actions: actions,
        icon: icon,
        iconColor: iconColor,
        height: height,
        showHandle: showHandle,
        isScrollControlled: isScrollControlled,
        padding: padding,
      ),
    );
  }
}

class ModernBottomSheetButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final IconData? icon;
  final double? width;

  const ModernBottomSheetButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.icon,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isDestructive) {
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red;
      borderColor = Colors.red.withOpacity(0.3);
    } else if (isPrimary) {
      backgroundColor = colorScheme.primary;
      textColor = Colors.white;
      borderColor = colorScheme.primary;
    } else {
      backgroundColor = isDark
          ? Colors.grey[700]!.withOpacity(0.5)
          : Colors.grey[200]!.withOpacity(0.5);
      textColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;
      borderColor = isDark
          ? Colors.grey[600]!.withOpacity(0.5)
          : Colors.grey[300]!.withOpacity(0.5);
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernBottomSheetSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  const ModernBottomSheetSearchField({
    Key? key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.5)
            : Colors.grey[100]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey[600]!.withOpacity(0.3)
              : Colors.grey[300]!.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged != null ? (_) => onChanged!() : null,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.grey[800],
          fontFamily: 'Tajawal',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[500],
            fontFamily: 'Tajawal',
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                )
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
