import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class AddNewProductSectionTitle extends StatelessWidget {
  const AddNewProductSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppFonts.styleBold18.copyWith(color: AppColors.oppositeColor),
    );
  }
}
