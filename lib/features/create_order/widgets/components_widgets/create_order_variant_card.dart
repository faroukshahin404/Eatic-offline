import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../model/create_order_variant_model.dart';

/// Card showing variant name and price. Price is from [priceForSelectedList] when set.
class CreateOrderVariantCard extends StatelessWidget {
  const CreateOrderVariantCard({
    super.key,
    required this.variant,
    required this.name,
    this.priceForSelectedList,
  });

  final CreateOrderVariantModel variant;
  final String name;
  /// Price for the currently selected price list; if null, [variant.basePrice] is used.
  final double? priceForSelectedList;

  @override
  Widget build(BuildContext context) {
    final price = priceForSelectedList ?? variant.basePrice;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: AppFonts.styleBold14.copyWith(color: AppColors.oppositeColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$price',
              style: AppFonts.styleBold14.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
