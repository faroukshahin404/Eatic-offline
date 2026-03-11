import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Outlined green button for "No" / cancel in custody dialogs.
class CustodyOutlinedButton extends StatelessWidget {
  const CustodyOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
      child: Text(label),
    );
  }
}
