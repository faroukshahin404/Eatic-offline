import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../cubit/create_order_cubit.dart';
import 'variant_column.dart';

/// Horizontal layout: one column per variable, each with header and radio options.
class VariantsColumnLayout extends StatelessWidget {
  const VariantsColumnLayout({super.key, required this.cubit});

  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'create_order.variants_count'.tr(),
            style: AppFonts.styleBold14.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  cubit.variableGroups.map((group) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: group == cubit.variableGroups.last ? 0 : 8,
                        left: 8,
                      ),
                      child: VariantColumn(group: group, cubit: cubit),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
