import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../cubit/create_order_cubit.dart';

/// Section listing addons only when a variant is selected. Add/Remove buttons (no counter).
class CreateOrderAddonsSection extends StatelessWidget {
  const CreateOrderAddonsSection({super.key, required this.cubit});

  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit.selectedVariant == null) return const SizedBox.shrink();

    final addons = cubit.addons;
    if (addons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'create_order.addons_count'.tr(namedArgs: {'count': '${addons.length}'}),
            style: AppFonts.styleBold16.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
        ),
        Card(
          elevation: 1,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: addons.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final addon = addons[i];
              final price = cubit.selectedVariant!.addonPrices[addon.addonId] ?? addon.price;
              final isSelected = cubit.isAddonSelected(addon.addonId);
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    '${i + 1}',
                    style: AppFonts.styleBold10.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text(
                  addon.name,
                  style: AppFonts.styleBold14.copyWith(
                    color: AppColors.oppositeColor,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$price',
                      style: AppFonts.styleBold14.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: Text('create_order.remove'.tr()),
                      onPressed: isSelected ? () => cubit.removeAddon(addon.addonId) : null,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: Text('create_order.add'.tr()),
                      onPressed: !isSelected ? () => cubit.addAddon(addon.addonId) : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
