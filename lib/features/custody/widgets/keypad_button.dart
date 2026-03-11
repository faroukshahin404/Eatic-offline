import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

/// Single keypad button (digit or delete) for the custody amount keypad.
class KeypadButton extends StatelessWidget {
  const KeypadButton({
    super.key,
    required this.keyValue,
    required this.onKey,
    String? label,
  }) : label = label ?? keyValue;

  final String keyValue;
  final String label;
  final void Function(String) onKey;

  @override
  Widget build(BuildContext context) {
    final isDelete = keyValue == 'delete';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => onKey(keyValue),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 56,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: isDelete ? AppColors.primary : AppColors.greyE6E9EA,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppFonts.styleBold16.copyWith(
                color: isDelete ? AppColors.primary : AppColors.oppositeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
