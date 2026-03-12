import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../cubit/cart_state.dart';
import 'discount_amount_dialog.dart';
// import 'discount_coupon_dialog.dart'; // Coupon discount temporarily disabled.
import 'discount_percentage_dialog.dart';

class CartFooterDiscountSection extends StatelessWidget {
  const CartFooterDiscountSection({
    super.key,
    this.onTap,
    this.onDiscountTypeSelected,
  });

  final VoidCallback? onTap;

  /// Called when user picks an option from the discount type popover (before showing the dialog).
  final void Function(CartDiscountType type)? onDiscountTypeSelected;

  static const double _menuWidth = 220;
  static const double _itemHeight = 48;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: 'cart.add_discount'.tr(),
          style: AppFonts.styleMedium16.copyWith(
            color: AppColors.oppositeColor,
          ),
        ),
        Builder(
          builder: (ctx) {
            return InkWell(
              onTap: () => _showDiscountTypeMenu(ctx),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fillColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.greyE6E9EA),
                ),
                child: Text(
                  'cart.discount_type'.tr(),
                  style: AppFonts.styleMedium14.copyWith(
                    color: AppColors.greyA4ACAD,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDiscountTypeMenu(BuildContext context) {
    onTap?.call();
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final offset = box.localToGlobal(Offset.zero);
    const menuHeight = _itemHeight * 3;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final left = (offset.dx + (box.size.width - _menuWidth) / 2).clamp(
      8.0,
      screenWidth - _menuWidth - 8,
    );
    final top = (offset.dy - menuHeight - 8).clamp(8.0, double.infinity);
    final position = RelativeRect.fromLTRB(
      left,
      top,
      left + _menuWidth,
      offset.dy,
    );
    showMenu<CartDiscountType>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      elevation: 8,
      items: [
        _buildMenuItem(
          context,
          CartDiscountType.amount,
          'cart.discount_type_amount'.tr(),
        ),
        _buildMenuItem(
          context,
          CartDiscountType.percentage,
          'cart.discount_type_percentage'.tr(),
        ),
        // Coupon discount temporarily disabled.
        // _buildMenuItem(
        //   context,
        //   CartDiscountType.coupon,
        //   'cart.discount_type_coupon'.tr(),
        // ),
      ],
    ).then((selected) {
      if (selected != null) {
        onDiscountTypeSelected?.call(selected);
        if (!context.mounted) return;
        switch (selected) {
          case CartDiscountType.amount:
            showDialog(
              context: context,
              builder: (_) => const DiscountAmountDialog(),
            );
            break;
          case CartDiscountType.percentage:
            showDialog(
              context: context,
              builder: (_) => const DiscountPercentageDialog(),
            );
            break;
          case CartDiscountType.coupon:
            // Coupon discount temporarily disabled; dialog not shown.
            break;
        }
      }
    });
  }

  PopupMenuItem<CartDiscountType> _buildMenuItem(
    BuildContext context,
    CartDiscountType type,
    String label,
  ) {
    return PopupMenuItem<CartDiscountType>(
      value: type,
      height: _itemHeight,
      child: Text(
        label,
        style: AppFonts.styleSemiBold16.copyWith(
          color: AppColors.oppositeColor,
        ),
      ),
    );
  }
}
