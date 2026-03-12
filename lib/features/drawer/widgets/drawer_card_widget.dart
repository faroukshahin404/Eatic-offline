import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_assets_image.dart';
import '../../../core/widgets/custom_text.dart';
import '../models/drawer_card_model.dart';

class DrawerCardWidget extends StatelessWidget {
  const DrawerCardWidget({
    super.key,
    required this.drawerCard,
    required this.isSelected,
  });

  final DrawerCardModel drawerCard;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: const EdgeInsets.all(7),
      duration: Duration(milliseconds: isSelected ? 300 : 0),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomAssetImage(
            image: drawerCard.icon,
            height: 30,
            color: isSelected
                ? AppColors.deepPrimary
                : AppColors.inactiveTextColor,
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: CustomText(
              text: drawerCard.title,
              style: AppFonts.styleMedium14.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.inactiveTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
