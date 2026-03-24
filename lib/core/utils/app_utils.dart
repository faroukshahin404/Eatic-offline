import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services_locator/service_locator.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../data/sqLite/database_service.dart';
import '../services/flutter_secure_storage.dart';

enum ScreenState {
  loading,
  loaded,
  error,
}

abstract class AppUtils {
  static double? devicePixelRatio;

  static double getDevicePixelRatio() {
    if (devicePixelRatio != null) return devicePixelRatio!;
    return MediaQuery.of(navigatorKey.currentContext!).devicePixelRatio;
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> appSetup() async {
    await setupDI();
    SecureLocalStorageService.init();
    await getIt<DatabaseService>().init();
  }

  static Future<void> copyTextWithSnackBar(String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    if ((navigatorKey.currentContext?.mounted ?? false)) return;
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Center(
          child: Text(
            "copy".tr(),
            style: AppFonts.styleBold18.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  static String number(dynamic number) {
    if (navigatorKey.currentContext?.locale.languageCode == "ar") {
      return NumberFormat('#.##', 'ar_EG').format(number);
    } else {
      return number.toString();
    }
  }

  static bool isArabic(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  static String getDeviceLang() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final languageCode = deviceLocale.languageCode.toLowerCase();

    if (languageCode == 'ar') {
      return 'ar';
    }
    return 'en';
  }
}
