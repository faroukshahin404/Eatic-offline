import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/widgets/custom_assets_image.dart';
import '../features/activation/services/activation_launch_service.dart';
import '../routes/app_paths.dart';
import '../services_locator/service_locator.dart';

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
        final launchService = getIt<ActivationLaunchService>();
        final destination = await launchService.resolveNextDestination();
        if (!mounted) return;

        switch (destination) {
          case ActivationLaunchDestination.installation:
            context.go(AppPaths.installation);
            break;
          case ActivationLaunchDestination.login:
            context.go(AppPaths.login);
            break;
          case ActivationLaunchDestination.setup:
            context.go(AppPaths.setup);
            break;
          case ActivationLaunchDestination.syncing:
            context.go(AppPaths.syncing);
            break;
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
          builder:
              (context, value, child) => Opacity(
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
