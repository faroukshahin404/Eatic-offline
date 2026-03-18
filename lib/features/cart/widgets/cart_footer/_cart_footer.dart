import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../payment_methods/model/payment_method_model.dart';
import '../../cubit/cart_cubit.dart';
import '../../cubit/cart_state.dart';
import 'cart_footer_confirm_button.dart';
import 'cart_footer_discount_section.dart';
import 'cart_footer_summary_row.dart';

class CartFooter extends StatelessWidget {
  const CartFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (prev, curr) =>
          prev.submitError != curr.submitError ||
          prev.submitSuccess != curr.submitSuccess,
      listener: (context, state) {
        if (state.submitError != null && state.submitError!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.submitError!)),
          );
        }
        if (state.submitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('cart.order_submitted'.tr())),
          );
          context.read<CartCubit>().clearSubmitSuccess();
        }
      },
      buildWhen: (prev, curr) =>
          prev.items != curr.items ||
          prev.selectedDiscountType != curr.selectedDiscountType ||
          prev.discountAmount != curr.discountAmount ||
          prev.discountPercentage != curr.discountPercentage ||
          prev.discountCouponCode != curr.discountCouponCode ||
          prev.isSubmitting != curr.isSubmitting ||
          prev.paymentMethods != curr.paymentMethods ||
          prev.selectedPaymentMethod != curr.selectedPaymentMethod,
      builder: (context, state) {
        final currency = 'products.currency'.tr();
        final totalFromItems = state.items.fold<double>(
          0,
          (sum, line) => sum + line.lineTotal,
        );
        final discountValue = _computeDiscountValue(state, totalFromItems);
        final finalTotal = (totalFromItems - discountValue).clamp(0.0, double.infinity);
        final totalBeforeDiscount = totalFromItems.toStringAsFixed(0);
        final totalStr = finalTotal.toStringAsFixed(0);
        final discountStr = discountValue.toStringAsFixed(0);

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              CartFooterSummaryRow(
                label: 'cart.total_before_discount'.tr(),
                value: '$totalBeforeDiscount $currency',
                style: AppFonts.styleMedium16.copyWith(
                  color: AppColors.oppositeColor,
                ),
              ),
              const SizedBox(height: 5),
              const CartFooterDiscountSection(),
              if (discountValue > 0) ...[
                const SizedBox(height: 8),
                CartFooterSummaryRow(
                  label: 'cart.discount'.tr(),
                  value: '-$discountStr $currency',
                  style: AppFonts.styleMedium16.copyWith(
                    color: AppColors.oppositeColor,
                  ),
                ),
              ],
              const Divider(color: AppColors.greyE6E9EA, height: 30),
              CartFooterSummaryRow(
                label: 'cart.total'.tr(),
                value: '$totalStr $currency',
                style: AppFonts.styleSemiBold16.copyWith(
                  color: AppColors.oppositeColor,
                ),
              ),
              const SizedBox(height: 12),
              _PaymentMethodSection(
                paymentMethods: state.paymentMethods,
                selected: state.selectedPaymentMethod,
                onChanged: (PaymentMethodModel? p) =>
              context.read<CartCubit>().setSelectedPaymentMethod(p),
              ),
              const SizedBox(height: 16),
              CartFooterConfirmButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => context.read<CartCubit>().submitOrder(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Payment method dropdown or Cash fallback when list is empty.
  /// [value] must be the same instance as one of [items] for DropdownButton; we resolve by id/name.
  static Widget _PaymentMethodSection({
    required List<PaymentMethodModel> paymentMethods,
    required PaymentMethodModel? selected,
    required ValueChanged<PaymentMethodModel?> onChanged,
  }) {
    if (paymentMethods.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'cart.payment_method'.tr(),
            style: AppFonts.styleMedium16.copyWith(color: AppColors.oppositeColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Cash',
            style: AppFonts.styleRegular18.copyWith(color: AppColors.oppositeColor),
          ),
        ],
      );
    }
    // Use the list item that matches selected (by id/name) so value is in items and assertion holds.
    final valueInList = _paymentMethodInList(paymentMethods, selected) ?? paymentMethods.first;
    return CustomDropDown<PaymentMethodModel>(
      items: paymentMethods,
      value: valueInList,
      onChanged: onChanged,
      itemLabelBuilder: (p) => p.name ?? 'Cash',
      label: 'cart.payment_method'.tr(),
      hideWhenEmpty: false,
      emptyMessage: 'Cash',
    );
  }

  static PaymentMethodModel? _paymentMethodInList(
    List<PaymentMethodModel> list,
    PaymentMethodModel? selected,
  ) {
    if (list.isEmpty || selected == null) return null;
    final selectedId = selected.id;
    final selectedName = selected.name ?? 'Cash';
    try {
      return list.firstWhere((p) {
        if (selectedId != null) return p.id == selectedId;
        return (p.name ?? 'Cash') == selectedName;
      });
    } catch (_) {
      return null;
    }
  }

  /// Computes the discount amount in currency from current discount state.
  static double _computeDiscountValue(CartState state, double totalFromItems) {
    switch (state.selectedDiscountType) {
      case CartDiscountType.amount:
        final amount = state.discountAmount ?? 0;
        return amount.clamp(0.0, totalFromItems);
      case CartDiscountType.percentage:
        final pct = state.discountPercentage ?? 0;
        if (pct <= 0 || pct > 100) return 0;
        return totalFromItems * (pct / 100);
      case CartDiscountType.coupon:
        // Coupon value not stored yet; can be added when API returns discount amount.
        return 0;
      case null:
        return 0;
    }
  }
}
