import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../../custody/widgets/custody_confirm_close_dialog.dart';
import '../../custody/widgets/custody_confirm_open_dialog.dart';
import '../cubit/cart_cubit.dart';

/// Outlined-style button: opens or closes custody based on [hasOpenCustody].
class CartCloseCustodyButton extends StatelessWidget {
  const CartCloseCustodyButton({super.key, required this.hasOpenCustody});

  final bool hasOpenCustody;

  @override
  Widget build(BuildContext context) {
    return CustomButtonWidget(
      text: 'cart.close_custody'.tr(),
      onPressed: () => _onPressed(context),
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    final cartCubit = context.read<CartCubit>();
    if (hasOpenCustody) {
      final result = await showCustodyConfirmCloseDialog(context);
      if (context.mounted && result == true) cartCubit.setHasOpenCustody(false);
    } else {
      final result = await showCustodyConfirmOpenDialog(context);
      if (context.mounted && result == true) cartCubit.setHasOpenCustody(true);
    }
  }
}
