import 'package:flutter/material.dart';

import '../utils/app_utils.dart';

class CustomAssetImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final Color? color;
  const CustomAssetImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = AppUtils.getDevicePixelRatio();
    return Image.asset(
      image,
      color: color,
      height: height,
      width: width,
      cacheHeight: height != null ? (height! * devicePixelRatio).round() : null,
      cacheWidth: width != null ? (width! * devicePixelRatio).round() : null,
    );
  }
}
