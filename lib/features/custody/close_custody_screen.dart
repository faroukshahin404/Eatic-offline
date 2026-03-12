import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../services_locator/service_locator.dart';
import 'cubit/custody_cubit.dart';
import 'cubit/custody_state.dart';
import 'widgets/custody_amount_dialog.dart';
import 'widgets/custody_filled_button.dart';
import 'widgets/custody_outlined_button.dart';

/// Close custody confirmation content: "Do you want to close the custody?" with No / Yes.
/// Uses [BlocConsumer] to show success and close on [CustodyCloseSuccess].
class CloseCustodyScreen extends StatelessWidget {
  const CloseCustodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustodyCubit>(
      create: (context) => getIt<CustodyCubit>(),
      child: BlocConsumer<CustodyCubit, CustodyState>(
        listenWhen: (prev, next) => next is CustodyCloseSuccess,
        listener: (context, state) {
          if (state is CustodyCloseSuccess) {
            context.read<CustodyCubit>().restoreAfterClose();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('custody.closed')),
                backgroundColor: Colors.green.shade700,
              ),
            );
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                      const SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          context.tr('custody.close_confirm'),
                          textAlign: TextAlign.center,
                          style: AppFonts.styleBold18.copyWith(
                            color: AppColors.oppositeColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(false),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustodyOutlinedButton(
                        label: context.tr('custody.no'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      const SizedBox(width: 16),
                      CustodyFilledButton(
                        label: context.tr('custody.yes'),
                        onPressed: () => _onYesPressed(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onYesPressed(BuildContext context) async {
    final amount = await showCustodyAmountDialog(context);
    if (amount == null || !context.mounted) return;
    await context.read<CustodyCubit>().closeCustody(amount);
  }
}
