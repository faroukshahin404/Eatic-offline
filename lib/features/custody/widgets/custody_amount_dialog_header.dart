import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../cubit/custody_cubit.dart';

/// Dialog header with title and close button for the custody amount dialog.
class CustodyAmountDialogHeader extends StatelessWidget {
  const CustodyAmountDialogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            context.tr('custody.enter_amount'),
            textAlign: TextAlign.center,
            style: AppFonts.styleBold18.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<CustodyCubit>().restoreAfterAmountDialog();
            Navigator.of(context).pop();
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}
