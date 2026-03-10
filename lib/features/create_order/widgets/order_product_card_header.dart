import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:ui' as ui;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../routes/app_paths.dart';
import '../../_main/cubit/main_cubit.dart';

/// Header row: product title on one side, total price on the other (RTL).
class OrderProductCardHeader extends StatelessWidget {
  const OrderProductCardHeader({super.key, required this.title, this.total});

  final String title;
  final double? total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: ui.TextDirection.rtl,
      children: [
        Expanded(
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
        ),
        if (total != null && total! > 0) ...[
          const SizedBox(width: 4),
          Text(
            '$total',
            style: AppFonts.styleBold22.copyWith(
              color: AppColors.oppositeColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
