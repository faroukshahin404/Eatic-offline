import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.fillColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.greyA4ACAD,
          ),
        ),

        child: InkWell(
          onTap: onTap,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                label,
                style: AppFonts.styleMedium18.copyWith(
                  color: isSelected ? Colors.white : AppColors.oppositeColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
