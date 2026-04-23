import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../custody/model/custody_model.dart';

/// Shows a simple dialog with shift/custody details.
class ShiftDetailsDialog extends StatelessWidget {
  const ShiftDetailsDialog({super.key, required this.custody});

  final CustodyModel custody;

  static void show(BuildContext context, CustodyModel custody) {
    showDialog(
      context: context,
      builder: (_) => ShiftDetailsDialog(custody: custody),
    );
  }

  static String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat(
        'd MMM yyyy, HH:mm',
        'en',
      ).format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftStartedAt = custody.shiftStartedAt ?? custody.createdAt;
    return AlertDialog(
      title: Text('shifts.details'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${'table.id'.tr()}: ${custody.id}'),
          const SizedBox(height: 8),
          Text('${'table.name'.tr()}: ${custody.userModel?.name ?? '-'}'),
          const SizedBox(height: 8),
          Text('${'shifts.started_at'.tr()}: ${_formatTime(shiftStartedAt)}'),
          const SizedBox(height: 8),
          Text(
            '${'shifts.ended_at'.tr()}: ${_formatTime(custody.shiftEndedAt)}',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('dialog.cancel'.tr()),
        ),
      ],
    );
  }
}
