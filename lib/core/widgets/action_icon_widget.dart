import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ActionIcon extends StatelessWidget {
  const ActionIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.backgroundColor,
    this.borderColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 22, color: iconColor),
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.all(8),
          backgroundColor: backgroundColor,
          foregroundColor: iconColor,
          hoverColor: AppColors.secondary.withValues(alpha: 0.45),
          side: borderColor == null ? null : BorderSide(color: borderColor!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
