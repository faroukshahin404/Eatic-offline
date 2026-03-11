import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/custody_cubit.dart';
import '../close_custody_screen.dart';

/// Confirmation dialog: "Do you want to close the custody?" with No / Yes.
/// [context] must have [CustodyCubit] provided. On Yes: shows amount dialog, closes the last open custody, and [BlocConsumer] shows success and closes on [CustodyCloseSuccess].
Future<bool?> showCustodyConfirmCloseDialog(BuildContext context) {
  final cubit = context.read<CustodyCubit>();
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BlocProvider.value(
      value: cubit,
      child: const CloseCustodyScreen(),
    ),
  );
}
