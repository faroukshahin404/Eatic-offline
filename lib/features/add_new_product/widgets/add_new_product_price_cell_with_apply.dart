import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class AddNewProductPriceCellWithApply extends StatefulWidget {
  const AddNewProductPriceCellWithApply({
    super.key,
    required this.value,
    required this.onChanged,
    required this.applyLabel,
    required this.onApply,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String applyLabel;
  final ValueChanged<double> onApply;

  @override
  State<AddNewProductPriceCellWithApply> createState() =>
      _AddNewProductPriceCellWithApplyState();
}

class _AddNewProductPriceCellWithApplyState
    extends State<AddNewProductPriceCellWithApply> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatNumber(widget.value));
  }

  @override
  void didUpdateWidget(covariant AddNewProductPriceCellWithApply oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = _formatNumber(widget.value);
    }
  }

  static String _formatNumber(double value) {
    final n = value.toInt();
    return n == 0 ? '' : n.toString();
  }

  static double _parseNumber(String text) =>
      (int.tryParse(text) ?? 0).toDouble();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
        ),
        const SizedBox(height: 2),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4),
            minimumSize: const Size(0, 28),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppColors.primary,
          ),
          onPressed: () {
            final val = _parseNumber(_controller.text);
            widget.onChanged(val);
            widget.onApply(val);
          },
          child: Text(
            widget.applyLabel,
            style: AppFonts.styleRegular12.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
