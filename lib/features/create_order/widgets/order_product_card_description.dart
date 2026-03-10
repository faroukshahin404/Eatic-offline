import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

/// Product description text block for the order card.
class OrderProductCardDescription extends StatelessWidget {
  const OrderProductCardDescription({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    if (description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        description,
        style: AppFonts.styleMedium18.copyWith(
          color: AppColors.oppositeColor,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textDirection: ui.TextDirection.rtl,
      ),
    );
  }
}
