import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

/// Generic dropdown form field for any model type [T].
/// Use [itemLabelBuilder] to map each item to its display text.
class CustomDropDown<T> extends StatelessWidget {
  const CustomDropDown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.label,
    this.validator,
    this.hideWhenEmpty = true,
    this.emptyMessage,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabelBuilder;
  final String? label;
  final String? Function(T?)? validator;

  /// When true, returns [SizedBox.shrink] when [items] is empty. When false, shows label and optional [emptyMessage].
  final bool hideWhenEmpty;
  final String? emptyMessage;

  static InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.mainColor),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      fillColor: AppColors.fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      if (hideWhenEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              textAlign: TextAlign.start,
              style: AppFonts.styleMedium18.copyWith(
                color: AppColors.oppositeColor,
              ),
            ),
            const SizedBox(height: 5),
          ],
          if (emptyMessage != null)
            Text(
              emptyMessage!,
              style: TextStyle(
                color: AppColors.greyA4ACAD,
                fontSize: 14,
                fontFamily: AppFonts.enFamily,
              ),
            ),
        ],
      );
    }

    final effectiveValue = value ?? items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            textAlign: TextAlign.start,
            style: AppFonts.styleMedium18.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
          const SizedBox(height: 5),
        ],
        DropdownButtonFormField<T>(
          value: effectiveValue,
          decoration: _dropdownDecoration(),
          dropdownColor: AppColors.fillColor,
          style: AppFonts.styleRegular18.copyWith(
            color: AppColors.oppositeColor,
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.greyA4ACAD),
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabelBuilder(item),
                    style: AppFonts.styleRegular18.copyWith(
                      fontFamily: AppFonts.enFamily,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
