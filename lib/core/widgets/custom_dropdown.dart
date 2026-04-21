import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

/// Generic dropdown form field for any model type [T].
/// Use [itemLabelBuilder] to map each item to its display text.
class CustomDropDown<T> extends StatefulWidget {
  const CustomDropDown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.label,
    this.hint,
    this.validator,
    this.hideWhenEmpty = true,
    this.emptyMessage,
    this.leadingIcon,
    this.compact = false,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabelBuilder;
  final String? label;

  /// Shown inside the field when [label] is omitted or used as placeholder text.
  final String? hint;
  final String? Function(T?)? validator;
  final IconData? leadingIcon;

  /// When true, returns [SizedBox.shrink] when [items] is empty. When false, shows label and optional [emptyMessage].
  final bool hideWhenEmpty;
  final String? emptyMessage;

  /// Smaller typography, padding, and icons for toolbar-style filters.
  final bool compact;

  @override
  State<CustomDropDown<T>> createState() => _CustomDropDownState<T>();
}

class _CustomDropDownState<T> extends State<CustomDropDown<T>> {
  static const double _desktopRadius = 8;
  static const double _borderWidthDefault = 1;
  static const double _borderWidthFocus = 2;

  bool _hovered = false;

  OutlineInputBorder _outlineBorder(
    Color color, {
    double width = _borderWidthDefault,
  }) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: width),
    borderRadius: BorderRadius.circular(_desktopRadius),
  );

  InputDecoration _dropdownDecoration({
    required Color enabledOutlineColor,
    IconData? leadingIcon,
    String? hint,
    required bool compact,
  }) {
    final contentPadding =
        compact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    final hintStyle =
        compact
            ? AppFonts.styleRegular14.copyWith(color: AppColors.greyA4ACAD)
            : AppFonts.styleRegular15.copyWith(color: AppColors.greyA4ACAD);

    return InputDecoration(
      hintText: hint,
      hintStyle: hintStyle,
      isDense: true,
      border: _outlineBorder(AppColors.greyE6E9EA),
      enabledBorder: _outlineBorder(enabledOutlineColor),
      focusedBorder: _outlineBorder(
        AppColors.mainColor,
        width: _borderWidthFocus,
      ),
      errorBorder: _outlineBorder(AppColors.validationError),
      focusedErrorBorder: _outlineBorder(
        AppColors.validationError,
        width: _borderWidthFocus,
      ),
      filled: true,
      fillColor: AppColors.sheetBackground,
      contentPadding: contentPadding,
      prefixIcon:
          leadingIcon == null
              ? null
              : Icon(
                leadingIcon,
                color: AppColors.greyA4ACAD,
                size: compact ? 20 : 22,
              ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 44,
        minHeight: 40,
      ),
    );
  }

  TextAlign _titleAlign(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    return isRtl ? TextAlign.right : TextAlign.left;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      if (widget.hideWhenEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              textAlign: _titleAlign(context),
              style: AppFonts.styleMedium14.copyWith(
                height: 1.2,
                color: AppColors.oppositeColor,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (widget.emptyMessage != null)
            Text(
              widget.emptyMessage!,
              textAlign: _titleAlign(context),
              style: AppFonts.styleRegular14.copyWith(
                color: AppColors.greyA4ACAD,
                fontFamily: AppFonts.enFamily,
              ),
            ),
        ],
      );
    }

    final effectiveValue = widget.value ?? widget.items.first;
    final enabledOutlineColor =
        _hovered ? AppColors.greyA4ACAD : AppColors.greyE6E9EA;

    final labelStyle = AppFonts.styleMedium14.copyWith(
      height: 1.2,
      color: AppColors.oppositeColor,
    );

    final fieldStyle =
        widget.compact
            ? AppFonts.styleRegular14.copyWith(
              color: AppColors.oppositeColor,
            )
            : AppFonts.styleRegular15.copyWith(
              color: AppColors.oppositeColor,
            );

    final itemTextStyle =
        widget.compact
            ? AppFonts.styleRegular14.copyWith(fontFamily: AppFonts.enFamily)
            : AppFonts.styleRegular15.copyWith(fontFamily: AppFonts.enFamily);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            textAlign: _titleAlign(context),
            style: labelStyle,
          ),
          SizedBox(height: widget.compact ? 4 : 6),
        ],
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: DropdownButtonFormField<T>(
            key: ValueKey<T>(effectiveValue),
            initialValue: effectiveValue,
            borderRadius: BorderRadius.circular(_desktopRadius),
            decoration: _dropdownDecoration(
              enabledOutlineColor: enabledOutlineColor,
              leadingIcon: widget.leadingIcon,
              hint: widget.label == null ? widget.hint : null,
              compact: widget.compact,
            ),
            dropdownColor: AppColors.sheetBackground,
            style: fieldStyle,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.greyA4ACAD,
              size: widget.compact ? 22 : 24,
            ),
            isExpanded: true,
            items:
                widget.items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          widget.itemLabelBuilder(item),
                          style: itemTextStyle,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: widget.onChanged,
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
