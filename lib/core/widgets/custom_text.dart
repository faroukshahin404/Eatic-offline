import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    this.needSelectable = false,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final bool needSelectable;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (needSelectable) {
      return SelectableText(
        text.tr(),
        maxLines: maxLines,
        textAlign: textAlign,
        style: style,
      );
    }
    return Text(
      text.tr(),
      maxLines: maxLines,
      textAlign: textAlign,
      style: style,
      overflow: maxLines == 1 ? TextOverflow.ellipsis : null,
    );
  }
}
