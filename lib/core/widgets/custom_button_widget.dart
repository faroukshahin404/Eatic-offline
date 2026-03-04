import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import 'custom_assets_image.dart';
import 'custom_loading.dart';
import 'custom_text.dart';

class CustomButtonWidget extends StatelessWidget {
  const CustomButtonWidget({
    super.key,
    this.text,
    this.image,
    this.imageWidth,
    this.imageHeight,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.iconFirst = false,
    this.isLoading = false,
    this.width,
    this.height,
  }) : assert(text != null || image != null, 'Provide at least text or image');

  final String? text;
  final String? image;
  final double? imageWidth;
  final double? imageHeight;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final bool iconFirst, isLoading;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? Colors.white;
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          backgroundColor ?? AppColors.primary,
        ),
        foregroundColor: WidgetStateProperty.all(fg),
        padding: WidgetStateProperty.all(
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        mouseCursor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return SystemMouseCursors.basic;
          }
          return SystemMouseCursors.click;
        }),
      ),
      child: AnimatedCrossFade(
        firstCurve: Curves.easeInOut,
        secondCurve: Curves.easeInOut,
        duration: Duration(milliseconds: 300),
        crossFadeState: isLoading
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        secondChild: CustomLoading(color: fg),
        firstChild: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image != null && iconFirst)
              CustomAssetImage(
                image: image!,
                width: imageWidth,
                height: imageHeight,
                color: fg,
              ),

            if (text != null)
              CustomText(
                text: text!,
                style: AppFonts.styleSemiBold16.copyWith(color: fg),
              ),

            if (image != null && !iconFirst)
              CustomAssetImage(
                image: image!,
                width: imageWidth,
                height: imageHeight,
                color: fg,
              ),
          ],
        ),
      ),
    );
    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }
    return button;
  }
}
