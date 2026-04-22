import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../routes/app_paths.dart';
import '../../../_main/cubit/main_cubit.dart';
import '../../../add_new_product/model/product_model.dart';
import '../../../cart/cubit/cart_cubit.dart';

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final cartCubit = context.read<CartCubit>();
        if (product.hasVariants == true) {
          context.read<MainCubit>().setCurrentScreen(
            screen: AppPaths.createOrder,
            data: {
              'productId': product.id,
              'priceListId': cartCubit.state.selectedOrderPriceListId,
            },
          );
          return;
        }
        final error = await cartCubit.addSimpleProductToCart(product);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'create_order.added_to_order'.tr()),
            backgroundColor:
                error == null ? Colors.green.shade700 : Colors.red.shade700,
          ),
        );
      },
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name ?? '',
                style: AppFonts.styleBold16.copyWith(
                  color: AppColors.oppositeColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (product.description?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  product.description ?? '',
                  style: AppFonts.styleRegular14.copyWith(
                    color: AppColors.greyA4ACAD,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              // Text(
              //   '$priceText $currency',
              //   style: AppFonts.styleBold14.copyWith(color: AppColors.primary),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
