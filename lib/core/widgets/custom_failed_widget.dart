import 'package:flutter/material.dart';

import '../constants/app_fonts.dart';
import 'custom_button_widget.dart';
import 'custom_text.dart';

class CustomFailedWidget extends StatelessWidget {
  const CustomFailedWidget({super.key, required this.message, this.onRetry});

  final String message;
  final void Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: message,
            style: AppFonts.styleBold18,
            needSelectable: true,
          ),
          CustomButtonWidget(
            text: 'retry_button',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
