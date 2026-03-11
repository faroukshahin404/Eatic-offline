import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../cubit/create_order_cubit.dart';
import '../../model/create_order_variant_model.dart';
import 'variant_column_header.dart';
import 'variant_option_tile.dart';

/// Single variant column: header (title + required chip) + list of radio options.
class VariantColumn extends StatelessWidget {
  const VariantColumn({
    super.key,
    required this.group,
    required this.cubit,
  });

  final CreateOrderVariableGroup group;
  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    final isInvalid = cubit.validationRequested &&
        cubit.invalidVariableIds.contains(group.variableId);

    return Container(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInvalid ? AppColors.validationError : AppColors.greyE6E9EA,
          width: isInvalid ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VariantColumnHeader(name: group.name),
            const SizedBox(height: 12),
            ...group.options.map(
              (option) => VariantOptionTile(
                option: option,
                selectedValueId: cubit.selectedValueIds[group.variableId],
                priceModifier: option.priceModifier,
                isInvalid: isInvalid,
                onTap: () => cubit.setSelectedVariableValue(
                  group.variableId,
                  option.valueId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
