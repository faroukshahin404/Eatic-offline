import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Filled dark green button for "Yes" / confirm in custody dialogs.
class CustodyFilledButton extends StatelessWidget {
  const CustodyFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
}
