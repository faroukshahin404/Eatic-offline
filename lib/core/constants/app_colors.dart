import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_fonts.dart';

abstract class AppColors {
  static const Color primary = Color(0xFF0d3b2d);
  static const Color secondary = Color(0xFFd2e8e2);
  static const Color deepPrimary = Color(0xFF426b60);

  static const Color inactiveTextColor = Color(0xFF9f9f9f);

  static const Color inactiveTextFieldBorderColor = Color(0xFF1a1a1a);

  /// Primary brand color used for focus states and accents (alias of primary).
  static const Color mainColor = primary;

  /// Grey used for hints and inactive prefix icons.
  static const Color greyA4ACAD = Color(0xFFA4ACAD);

  /// Default text color (opposite of background).
  static const Color oppositeColor = Color(0xFF1a1a1a);

  /// Border color for text fields (enabled/default state).
  static const Color greyE6E9EA = Color(0xFFE6E9EA);

  /// Background fill color for text fields.
  static const Color fillColor = Color(0xFFF5F5F5);

  static ThemeData androidTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xffffffff),
    useMaterial3: false,
    fontFamily: AppFonts.arFamily,

    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    primaryColor: AppColors.primary,
    primaryColorLight: AppColors.primary,
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      strokeCap: StrokeCap.round,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateColor.resolveWith((states) => AppColors.primary),
    ),
  );

  static CupertinoThemeData iosTheme = CupertinoThemeData(
    scaffoldBackgroundColor: Color(0xffffffff),
  );
}
