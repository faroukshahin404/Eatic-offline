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
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatNumber(widget.value));
    _focusNode = FocusNode();
  }

  static String _formatNumber(double value) {
    final n = value.toInt();
    return n == 0 ? '' : n.toString();
  }

  static double _parseNumber(String text) =>
      (int.tryParse(text) ?? 0).toDouble();

  /// Sync from parent when not editing, or when parent diverges (e.g. apply-all).
  bool _shouldSyncControllerFromParent(double newValue) {
    if (!_focusNode.hasFocus) return true;
    final fromField = _parseNumber(_controller.text);
    return (newValue - fromField).abs() > 1e-9;
  }

  @override
  void didUpdateWidget(AddNewProductPriceCellWithApply oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    if (!_shouldSyncControllerFromParent(widget.value)) return;
    final next = _formatNumber(widget.value);
    if (_controller.text != next) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) {
            widget.onChanged(_parseNumber(v));
          },
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
