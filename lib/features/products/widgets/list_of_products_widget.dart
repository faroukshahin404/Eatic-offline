import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../add_new_product/model/product_model.dart';

class ListOfProductsWidget extends StatelessWidget {
  const ListOfProductsWidget({
    super.key,
    required this.products,
    this.onEdit,
    this.onDelete,
  });

  final List<ProductModel> products;
  final void Function(ProductModel item)? onEdit;
  final void Function(ProductModel item)? onDelete;

  static String _priceText(ProductModel p) {
    if (p.defaultPrice != null && p.defaultPrice! > 0) {
      return p.defaultPrice!.toStringAsFixed(0);
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          'products.no_products'.tr(),
          style: TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: AppColors.greyE6E9EA),
      itemBuilder: (context, index) {
        final product = products[index];
        final name = product.name ?? product.nameEn ?? '-';
        final subtitle = _priceText(product);
        final hasVariants = product.hasVariants == true;

        return Material(
          color: index.isEven ? Colors.white : AppColors.fillColor,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: AppFonts.styleBold16.copyWith(
                            color: AppColors.oppositeColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        if (product.description != null &&
                            product.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.description!.trim(),
                            style: AppFonts.styleRegular12.copyWith(
                              color: AppColors.inactiveTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null) ...[
                    const SizedBox(width: 8),
                    if (onEdit != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.fillColor,
                          foregroundColor: AppColors.oppositeColor,
                        ),
                        onPressed: () => onEdit!(product),
                        child: Text('actions.edit'.tr()),
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: 8),
                    if (onDelete != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => onDelete!(product),
                        child: Text('actions.delete'.tr()),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
