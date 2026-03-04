import 'package:flutter/material.dart';

import '../utils/app_utils.dart';

abstract class AppSize {
  static const double tablet = 600;
  static const double desktop = 900;

  static bool isMobile() =>
      MediaQuery.sizeOf(AppUtils.navigatorKey.currentContext!).width <
      AppSize.tablet;
}
