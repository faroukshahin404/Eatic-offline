import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/custom_header_screen.dart';

/// Header row: product title on one side, total price on the other (RTL).
class OrderProductCardHeader extends StatelessWidget {
  const OrderProductCardHeader({
    super.key,
    required this.title,
    this.total,
    this.path,
  });

  final String title;
  final double? total;

  /// When set, back tap navigates to this path; when null, navigates to home.
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: ui.TextDirection.rtl,
      children: [
        Expanded(
          child: CustomHeaderScreen(title: title, path: path),
        ),
        const SizedBox(width: 16),
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
