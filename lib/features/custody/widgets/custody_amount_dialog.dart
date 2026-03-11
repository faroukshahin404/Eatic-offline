import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/custody_cubit.dart';
import 'custody_amount_dialog_content.dart';

/// Shows the custody amount dialog. Cubit is read from [context].
/// Returns the entered amount or null if dismissed.
Future<double?> showCustodyAmountDialog(BuildContext context) {
  final cubit = context.read<CustodyCubit>();
  cubit.startAmountEditing();
  return showDialog<double>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BlocProvider.value(
      value: cubit,
      child: const CustodyAmountDialogContent(),
    ),
  );
}
