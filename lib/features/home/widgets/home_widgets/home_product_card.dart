import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../routes/app_paths.dart';
import '../../../_main/cubit/main_cubit.dart';
import '../../../add_new_product/model/product_model.dart';

class HomeProductCard extends StatelessWidget {
  const HomeProductCard({super.key, required this.product});

  final ProductModel product;

  static String _displayPrice(ProductModel p) {
    if (p.defaultPrice != null && p.defaultPrice! > 0) {
      return p.defaultPrice!.toStringAsFixed(0);
    }
    return '0';
  }

  @override
  Widget build(BuildContext context) {
    final name = product.name ?? product.nameEn ?? '-';
    final description = product.description?.trim() ?? '';

    return InkWell(
      onTap: () {
        // context.push(AppPaths.createOrder, extra: product.id);
        context.read<MainCubit>().setCurrentScreen(AppPaths.createOrder , data: product.id);
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
                name,
                style: AppFonts.styleBold16.copyWith(
                  color: AppColors.oppositeColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
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
