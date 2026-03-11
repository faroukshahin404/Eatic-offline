import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../add_new_product/model/product_model.dart';
import '../../../custody/close_custody_screen.dart';

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        // context.push(AppPaths.createOrder, extra: product.id);
        // context.read<MainCubit>().setCurrentScreen(AppPaths.createOrder , data: product.id);
        showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => CloseCustodyScreen(),
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
