import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../../../routes/app_paths.dart';
import '../../_main/cubit/main_cubit.dart';

/// Outlined-style button that opens the Select Waiter screen.
class CartChooseWaiterButton extends StatelessWidget {
  const CartChooseWaiterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomButtonWidget(
        text: 'cart.choose_waiter'.tr(),
        onPressed:
            () => context.read<MainCubit>().setCurrentScreen(
              screen: AppPaths.selectWaiter,
            ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
      ),
    );
  }
}
