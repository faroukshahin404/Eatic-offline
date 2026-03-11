import 'package:flutter/material.dart';

import '../open_custody_screen.dart';

/// Shows the open custody confirmation dialog. Returns true if user confirmed and custody was created.
Future<bool?> showCustodyConfirmOpenDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const OpenCustodyScreen(),
  );
}
