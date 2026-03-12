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

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _obscure = false;
  final FocusNode _focusNode = FocusNode();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    );

    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
    final result = widget.validator != null
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

    final targetColor = _focusNode.hasFocus
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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!.tr(),
                textAlign: TextAlign.right,
                style:
                    widget.titleStyle ??
                    AppFonts.styleMedium18.copyWith(
                      color: widget.titleColor ?? AppColors.oppositeColor,
                    ),
              ),
              const SizedBox(height: 5),
            ],

            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                final dx =
                    math.sin(_shakeAnimation.value * 2 * math.pi * 3) * 8;
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                enabled: widget.enabled,
                style: AppFonts.styleRegular18,
                validator: _validate,
                // autovalidateMode: AutovalidateMode.onUserInteraction,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                obscureText: _obscure,
                cursorColor: AppColors.oppositeColor,
                onTap: widget.onTap,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,

                textAlign:
                    widget.textAlign ??
                    (AppUtils
                                .navigatorKey
                                .currentContext
                                ?.locale
                                .languageCode ==
                            'ar'
                        ? TextAlign.right
                        : TextAlign.left),
                inputFormatters: widget.isOnlyNumbers == true
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ]
                    : widget.inputFormatters,
                decoration: InputDecoration(
                  hintText: widget.hint.tr(),
                  hintStyle: AppFonts.styleRegular18.copyWith(
                    color: AppColors.greyA4ACAD,
                  ),

                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyE6E9EA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyE6E9EA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.mainColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  filled: true,
                  fillColor: widget.fillColor ?? AppColors.fillColor,
                  prefixIcon: widget.prefix != null ? _buildPrefixIcon() : null,
                  suffixIcon:
                      widget.suffix ??
                      (widget.isPassword
                          ? IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            )
                          : null),
                  contentPadding:
                      widget.contentPadding ??
                      EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: widget.paddingHeight ?? 17,
                      ),
                ),
              ),
            ),
          ],
        ),
        if (widget.onTap != null && widget.enabled == true) ...[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: widget.onTap,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ],
    );
  }
}
