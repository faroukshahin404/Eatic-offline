import 'package:flutter/material.dart';

import '../../cubit/create_order_cubit.dart';
import 'addon_row.dart';
import 'addons_section_header.dart';

/// Addons section: title with "Optional" chip and list of addons with checkbox and quantity selector.
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
        const AddonsSectionHeader(),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addons.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final addon = addons[i];
            final unitPrice =
                cubit.selectedVariant!.addonPrices[addon.addonId] ??
                addon.price;
            return AddonRow(
              addon: addon,
              unitPrice: unitPrice,
              quantity: cubit.getAddonQuantity(addon.addonId),
              onCheckChanged: (checked) {
                cubit.setAddonQuantity(addon.addonId, checked ? 1 : 0);
              },
              onIncrement: () => cubit.incrementAddon(addon.addonId),
              onDecrement: () => cubit.decrementAddon(addon.addonId),
            );
          },
        ),
      ],
    );
  }
}
