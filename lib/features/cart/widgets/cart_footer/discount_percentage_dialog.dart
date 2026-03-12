import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../custody/widgets/custody_filled_button.dart';
import '../../../custody/widgets/numeric_keypad.dart';
import '../../cubit/cart_cubit.dart';

class DiscountPercentageDialog extends StatefulWidget {
  const DiscountPercentageDialog({super.key});

  @override
  State<DiscountPercentageDialog> createState() => _DiscountPercentageDialogState();
}

class _DiscountPercentageDialogState extends State<DiscountPercentageDialog> {
  String _percentageText = '';

  void _onKey(String key) {
    if (key == 'delete') {
      if (_percentageText.isEmpty) return;
      setState(() => _percentageText = _percentageText.substring(0, _percentageText.length - 1));
    } else {
      setState(() => _percentageText += key);
    }
  }

  void _onEnter() {
    final value = _percentageText.trim().isEmpty ? null : double.tryParse(_percentageText.trim());
    context.read<CartCubit>().setDiscountByPercentage(value);
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
                    'cart.discount_percentage_title'.tr(),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyE6E9EA),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _percentageText.isEmpty ? '' : _percentageText,
                      style: AppFonts.styleRegular18.copyWith(color: AppColors.oppositeColor),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '%',
                      style: AppFonts.styleRegular18.copyWith(color: AppColors.oppositeColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              NumericKeypad(onKey: _onKey),
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
