
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

// class CustomLoading extends StatelessWidget {
//   const CustomLoading({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         child: CustomAssetImage(image: AppAssets.logo, height: 100, width: 100),
//       ),
//     );
//   }
// }

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator.adaptive(
        strokeWidth: 2,
        backgroundColor: color ?? AppColors.mainColor,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
