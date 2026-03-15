import 'package:flutter/material.dart';

import '../../../core/constants/app_fonts.dart';

class AddNewProductVariantLabelCell extends StatelessWidget {
  const AddNewProductVariantLabelCell({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.styleRegular14.copyWith(
              fontFamily: AppFonts.enFamily,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
