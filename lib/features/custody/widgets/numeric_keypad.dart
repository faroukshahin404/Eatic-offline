import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'keypad_button.dart';

/// Numeric keypad grid (1-9, 0, delete) for custody amount input.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({super.key, required this.onKey});

  final void Function(String) onKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['1', '2', '3']
              .map((k) => KeypadButton(keyValue: k, onKey: onKey))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['4', '5', '6']
              .map((k) => KeypadButton(keyValue: k, onKey: onKey))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['7', '8', '9']
              .map((k) => KeypadButton(keyValue: k, onKey: onKey))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KeypadButton(keyValue: '0', onKey: onKey),
            KeypadButton(
              keyValue: 'delete',
              label: context.tr('custody.delete'),
              onKey: onKey,
            ),
          ],
        ),
      ],
    );
  }
}
