import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/custody_cubit.dart';
import '../cubit/custody_state.dart';
import 'custody_amount_display.dart';
import 'custody_amount_dialog_header.dart';
import 'custody_filled_button.dart';
import 'numeric_keypad.dart';

/// Stateless content of the custody amount dialog. Reads amount from [CustodyCubit] state.
class CustodyAmountDialogContent extends StatelessWidget {
  const CustodyAmountDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustodyCubit, CustodyState>(
      buildWhen: (prev, next) => next is CustodyAmountEditing,
      builder: (context, state) {
        final amountText = state is CustodyAmountEditing
            ? state.amountText
            : '';
        final cubit = context.read<CustodyCubit>();

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
                  const CustodyAmountDialogHeader(),
                  const SizedBox(height: 16),
                  CustodyAmountDisplay(amountText: amountText),
                  const SizedBox(height: 20),
                  NumericKeypad(
                    onKey: (key) {
                      if (key == 'delete') {
                        cubit.deleteAmountLast();
                      } else {
                        cubit.appendAmountKey(key);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustodyFilledButton(
                      label: context.tr('custody.enter'),
                      onPressed: () {
                        final value = cubit.getAmountValue();
                        if (value != null) {
                          cubit.restoreAfterAmountDialog();
                          Navigator.of(context).pop(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
