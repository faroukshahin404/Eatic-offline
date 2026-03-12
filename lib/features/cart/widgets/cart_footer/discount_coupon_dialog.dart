import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../custody/widgets/custody_filled_button.dart';
import '../../cubit/cart_cubit.dart';

/// Coupon discount dialog. Temporarily disabled from UI and logic (setDiscountByCoupon commented in cubit).
class DiscountCouponDialog extends StatefulWidget {
  const DiscountCouponDialog({super.key});

  @override
  State<DiscountCouponDialog> createState() => _DiscountCouponDialogState();
}

class _DiscountCouponDialogState extends State<DiscountCouponDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    // Coupon discount temporarily disabled.
    // final code = _controller.text.trim().isEmpty ? null : _controller.text.trim();
    // context.read<CartCubit>().setDiscountByCoupon(code);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'cart.discount_coupon_title'.tr(),
                    style: AppFonts.styleSemiBold16.copyWith(color: AppColors.oppositeColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'cart.coupon_placeholder'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.greyE6E9EA),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: AppFonts.styleRegular18.copyWith(color: AppColors.oppositeColor),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustodyFilledButton(
                  label: 'custody.enter'.tr(),
                  onPressed: _onEnter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
