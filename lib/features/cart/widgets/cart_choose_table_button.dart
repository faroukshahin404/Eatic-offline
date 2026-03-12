import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../../../routes/app_paths.dart';
import '../../_main/cubit/main_cubit.dart';

/// Filled primary button that opens the Table Selection screen.
class CartChooseTableButton extends StatelessWidget {
  const CartChooseTableButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomButtonWidget(
        text: 'cart.choose_table'.tr(),
        onPressed: () => context.read<MainCubit>().setCurrentScreen(
              screen: AppPaths.selectTable,
            ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
