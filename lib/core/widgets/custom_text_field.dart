import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../utils/app_utils.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.title,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.isPassword = false,
    this.suffix,
    this.titleColor,
    this.fillColor,
    this.prefix,
    this.inputFormatters = const [],
    this.textAlign,
    this.contentPadding,
    this.paddingHeight,
    this.onTap,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.titleStyle,
    this.isOnlyNumbers = false,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.readOnly = false,
  });

  final String? title;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  final Widget? suffix;
  final Widget? prefix;
  final Color? titleColor;
  final Color? fillColor;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final double? paddingHeight;
  final void Function()? onTap;
  final int? maxLines, minLines, maxLength;
  final bool? enabled;
  final TextStyle? titleStyle;
  final bool? isOnlyNumbers;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool readOnly;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _obscure = false;
  bool _hovered = false;
  late final FocusNode _internalFocusNode;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  bool get _isEnabled => widget.enabled ?? true;

  void _handleFocusChanged() => setState(() {});

  static const double _desktopRadius = 8;
  static const double _borderWidthDefault = 1;
  static const double _borderWidthFocus = 2;

  OutlineInputBorder _outlineBorder(
    Color color, {
    double width = _borderWidthDefault,
  }) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: width),
    borderRadius: BorderRadius.circular(_desktopRadius),
  );

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
    _internalFocusNode = FocusNode();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    );

    _effectiveFocusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldFocusNode = oldWidget.focusNode ?? _internalFocusNode;
    final newFocusNode = widget.focusNode ?? _internalFocusNode;
    if (oldFocusNode != newFocusNode) {
      oldFocusNode.removeListener(_handleFocusChanged);
      newFocusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _internalFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '${widget.title?.tr() ?? widget.hint.tr()} ${"validation.required".tr()}';
    }
    return null;
  }

  String? _validate(String? value) {
    final result =
        widget.validator != null
            ? widget.validator!(value)
            : _defaultValidator(value);
    if (result != null && !_shakeController.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _shakeController.forward(from: 0),
      );
    }
    return result;
  }

  Widget _buildPrefixIcon() {
    if (widget.prefix == null) return const SizedBox.shrink();

    final targetColor =
        _effectiveFocusNode.hasFocus
            ? AppColors.mainColor
            : AppColors.greyA4ACAD;

    // Check if prefix is a Padding widget (common case)
    if (widget.prefix is Padding) {
      final padding = widget.prefix as Padding;
      return Padding(
        padding: padding.padding,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(targetColor, BlendMode.srcIn),
          child: padding.child,
        ),
      );
    }

    // For other widget types, wrap with ColorFiltered
    return ColorFiltered(
      colorFilter: ColorFilter.mode(targetColor, BlendMode.srcIn),
      child: widget.prefix!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl =
        AppUtils.navigatorKey.currentContext?.locale.languageCode == 'ar';
    final titleAlign = isRtl ? TextAlign.right : TextAlign.left;
    final fieldAlign = widget.textAlign ?? (isRtl ? TextAlign.right : TextAlign.left);

    final bool canHover = _isEnabled && !widget.readOnly;
    final Color enabledOutlineColor =
        canHover && _hovered
            ? AppColors.greyA4ACAD
            : AppColors.greyE6E9EA;

    final Color fieldFill = widget.fillColor ?? AppColors.sheetBackground;
    final EdgeInsetsGeometry effectivePadding =
        widget.contentPadding ??
        EdgeInsets.symmetric(
          horizontal: 12,
          vertical: widget.paddingHeight ?? 12,
        );

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!.tr(),
                textAlign: titleAlign,
                style:
                    widget.titleStyle ??
                    AppFonts.styleMedium14.copyWith(
                      height: 1.2,
                      color: widget.titleColor ?? AppColors.oppositeColor,
                    ),
              ),
              const SizedBox(height: 6),
            ],

            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final dx =
                    math.sin(_shakeAnimation.value * 2 * math.pi * 3) * 6;
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: MouseRegion(
                onEnter: (_) {
                  if (canHover) setState(() => _hovered = true);
                },
                onExit: (_) => setState(() => _hovered = false),
                cursor:
                    widget.readOnly && widget.onTap != null
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.text,
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _effectiveFocusNode,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  onChanged: widget.onChanged,
                  enabled: _isEnabled,
                  readOnly: widget.readOnly,
                  style: AppFonts.styleRegular15.copyWith(
                    color: _isEnabled
                        ? AppColors.oppositeColor
                        : AppColors.oppositeColor.withValues(alpha: 0.45),
                  ),
                  validator: _validate,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  obscureText: _obscure,
                  cursorColor: AppColors.mainColor,
                  onTap: widget.onTap,
                  maxLines:widget.isPassword ? 1 : widget.maxLines,
                  maxLength: widget.maxLength,
                  textAlign: fieldAlign,
                  inputFormatters:
                      widget.isOnlyNumbers == true
                          ? [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ]
                          : widget.inputFormatters,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: widget.hint.tr(),
                    hintStyle: AppFonts.styleRegular15.copyWith(
                      color: AppColors.greyA4ACAD,
                    ),
                    border: _outlineBorder(AppColors.greyE6E9EA),
                    enabledBorder: _outlineBorder(enabledOutlineColor),
                    focusedBorder: _outlineBorder(
                      AppColors.mainColor,
                      width: _borderWidthFocus,
                    ),
                    disabledBorder: _outlineBorder(
                      AppColors.greyE6E9EA.withValues(alpha: 0.55),
                    ),
                    errorBorder: _outlineBorder(AppColors.validationError),
                    focusedErrorBorder: _outlineBorder(
                      AppColors.validationError,
                      width: _borderWidthFocus,
                    ),
                    filled: true,
                    fillColor: _isEnabled
                        ? fieldFill
                        : AppColors.fillColor.withValues(alpha: 0.85),
                    prefixIcon: widget.prefix != null ? _buildPrefixIcon() : null,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 40,
                    ),
                    suffixIcon:
                        widget.suffix ??
                        (widget.isPassword
                            ? IconButton(
                              style: IconButton.styleFrom(
                                minimumSize: const Size(40, 40),
                                padding: const EdgeInsets.all(8),
                                foregroundColor: AppColors.greyA4ACAD,
                                hoverColor: AppColors.secondary.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                              onPressed:
                                  _isEnabled
                                      ? () => setState(() => _obscure = !_obscure)
                                      : null,
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 22,
                              ),
                            )
                            : null),
                    suffixIconConstraints:
                        widget.suffix == null && widget.isPassword
                            ? const BoxConstraints(minWidth: 44, minHeight: 40)
                            : null,
                    contentPadding: effectivePadding,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.onTap != null && _isEnabled) ...[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: widget.onTap,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
