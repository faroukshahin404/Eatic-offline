import 'package:flutter/material.dart';

import '../utils/app_utils.dart';
import 'app_size.dart';

abstract class AppFonts {
  static const String arFamily = 'ar';
  static const String enFamily = 'en';

  static String getCurrentFontFamilyBasedOnText(String text) =>
      AppUtils.isArabic(text) == true ? arFamily : enFamily;

  static String get familyBasedOnAppLang => "ar";
  // AppUtils.appLang == "ar" ? arFamily : enFamily;

  static Color get familyBasedOnThemeMode => Colors.black;
  // AppUtils.appThemeMode == "light" ? Colors.black : Colors.white;

  static TextStyle get styleBold24 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 24),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get styleBold40 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 40),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get stylerRegular40 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 40),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get styleMedium18 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 18),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get styleMedium20 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 20),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get styleMedium14 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 14),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w500,
  );
  static TextStyle get styleMedium15 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 15),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get styleMedium16 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 16),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get styleBold22 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 22),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get styleBold16 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 16),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get styleBold14 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 14),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get styleBold10 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 10),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get styleBold20 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 20),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get styleBold18 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 18),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get styleSemiBold18 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 18),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get styleSemiBold16 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 16),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get styleSemiBold22 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 22),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get styleMedium25 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 25),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get styleRegular14 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 14),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get styleRegular12 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 12),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get styleRegular18 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 18),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get styleRegular22 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 22),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get styleRegular15 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 15),
    color: familyBasedOnThemeMode,
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get styleSemiBold14 => TextStyle(
    fontSize: getResponsiveFontSize(fontSize: 14),
    fontFamily: familyBasedOnAppLang,
    fontWeight: FontWeight.w600,
  );

  static double getResponsiveFontSize({required double fontSize}) {
    final scaleFactor = getScaleFactor();

    final responsive = fontSize * scaleFactor;

    final lowerLimit = fontSize * 0.85;
    final upperLimit = fontSize * 1.35;

    return responsive.clamp(lowerLimit, upperLimit);
  }

  static double getScaleFactor() {
    final width = MediaQuery.sizeOf(
      AppUtils.navigatorKey.currentContext!,
    ).width;

    if (width < AppSize.tablet) {
      return width / 390;
    } else if (width < AppSize.desktop) {
      return width / 768;
    } else {
      final cappedWidth = width.clamp(1024, 1440);
      return cappedWidth / 1440;
    }
  }
}
