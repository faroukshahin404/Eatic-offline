import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class PosCrudSectionCard extends StatelessWidget {
  const PosCrudSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyE6E9EA),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PosCrudActionButton extends StatelessWidget {
  const PosCrudActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground =
        backgroundColor ?? (isPrimary ? AppColors.primary : Colors.white);
    final resolvedForeground =
        foregroundColor ?? (isPrimary ? Colors.white : AppColors.primary);
    final resolvedBorder =
        borderColor ?? (isPrimary ? AppColors.primary : AppColors.greyE6E9EA);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: AppFonts.styleSemiBold16.copyWith(color: resolvedForeground),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: resolvedBackground,
          foregroundColor: resolvedForeground,
          elevation: isPrimary ? 0 : 0,
          side: BorderSide(color: resolvedBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
