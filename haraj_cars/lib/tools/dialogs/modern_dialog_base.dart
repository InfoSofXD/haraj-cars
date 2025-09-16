import 'package:flutter/material.dart';
import 'dart:ui';

class ModernDialogBase extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final IconData? icon;
  final Color? iconColor;
  final double? width;
  final double? height;

  const ModernDialogBase({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
    this.icon,
    this.iconColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width ?? 400,
        height: height,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.grey[800]!.withOpacity(0.9),
                          Colors.grey[700]!.withOpacity(0.8),
                        ]
                      : [
                          Colors.white.withOpacity(0.95),
                          Colors.grey[50]!.withOpacity(0.9),
                        ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon and title
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
                      padding: const EdgeInsets.all(24),
                      child: content,
                    ),
                  ),

                  // Actions
                  if (actions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions
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
      ),
    );
  }
}

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final IconData? icon;
  final double? width;

  const ModernButton({
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
