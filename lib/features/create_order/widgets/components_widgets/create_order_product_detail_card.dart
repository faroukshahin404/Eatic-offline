import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../add_new_product/model/product_model.dart';
import 'chip_label.dart';

/// Card showing product name, description, and summary chips (default price, has variants, counts).
class CreateOrderProductDetailCard extends StatelessWidget {
  const CreateOrderProductDetailCard({
    super.key,
    this.product,
    required this.variantsCount,
    required this.addonsCount,
  });

  final ProductModel? product;
  final int variantsCount;
  final int addonsCount;

  @override
  Widget build(BuildContext context) {
    if (product == null) return const SizedBox.shrink();
    final p = product!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.name ?? '',
              style: AppFonts.styleBold18.copyWith(
                color: AppColors.oppositeColor,
              ),
            ),
            if (p.description != null && p.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                p.description!,
                style: AppFonts.styleRegular14.copyWith(
                  color: AppColors.greyA4ACAD,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                ChipLabel(
                  label: 'create_order.default_price'.tr(),
                  value: '${p.defaultPrice ?? '-'}',
                ),
                ChipLabel(
                  label: 'create_order.has_variants'.tr(),
                  value: p.hasVariants == true ? 'create_order.yes'.tr() : 'create_order.no'.tr(),
                ),
                ChipLabel(label: 'create_order.variants'.tr(), value: '$variantsCount'),
                ChipLabel(label: 'create_order.addons'.tr(), value: '$addonsCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
