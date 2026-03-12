import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/services/flutter_secure_storage.dart';
import '../core/utils/app_utils.dart';
import '../core/widgets/custom_assets_image.dart';
import '../routes/app_paths.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Duration duration = const Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(duration, () async {
        final user = await SecureLocalStorageService.readSecureData("user");
        if (user.isNotEmpty) {
          AppUtils.navigatorKey.currentContext?.go(AppPaths.main);
        } else {
          AppUtils.navigatorKey.currentContext?.go(AppPaths.login);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: duration,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Hero(
              tag: 'logo',
              child: CustomAssetImage(image: AppAssets.logo, height: 200),
            ),
          ),
        ),
      ),
    );
  }
}
