import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../routes/app_paths.dart';
import '../../../_main/cubit/main_cubit.dart';

/// Back button with product title; tap navigates to home.
class OrderProductCardBackTitle extends StatelessWidget {
  const OrderProductCardBackTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        onTap: () {
          context.read<MainCubit>().setCurrentScreen(AppPaths.home);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.oppositeColor,
              size: 30,
            ),
            Text(
              title,
              style: AppFonts.styleBold40.copyWith(
                color: AppColors.oppositeColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
