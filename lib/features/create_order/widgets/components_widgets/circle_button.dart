import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Circular +/- button; grey when inactive, dark green when active.
class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.greyA4ACAD;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.15)
                : AppColors.greyE6E9EA,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? color : AppColors.greyA4ACAD.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? color : AppColors.greyA4ACAD,
          ),
        ),
      ),
    );
  }
}
