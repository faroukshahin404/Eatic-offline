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

  /// Background color for modal bottom sheets (avoids theme surface tint).
  static const Color sheetBackground = Color(0xFFFFFFFF);

  /// Validation error state (e.g. required variant not selected).
  static const Color validationError = Color(0xFFD32F2F);

  /// Table card: available (empty, selectable).
  static const Color tableAvailableBg = Color(0xFFE0E0E0);
  static const Color tableAvailableBorder = Color(0xFFE0E0E0);

  /// Table card: occupied (is_empty == 0, not selectable).
  static const Color tableOccupiedBg = Color(0xffa2e5c4);
  static const Color tableOccupiedBorder = Color(0xFFf0c0c0);

  /// Table card: selected by user.
  static const Color tableSelectedBg = Color(0xFFE8F5E9);
  static const Color tableSelectedBorder = Color(0xFF81C784);
  static const Color tableNotEmpty = Color(0xfff0c0c0);

  /// Orders-status tables grid: free card.
  static const Color tableFreeBg = Color(0xFFE8F8F0);
  static const Color tableFreeBorder = Color(0xFFB2DFDB);

  /// Orders-status tables grid: occupied / active card.
  static const Color tableActiveBg = Color(0xFFFDF0F0);
  static const Color tableActiveBorder = Color(0xFFF5C6C6);

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
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: BorderSide(
        color: AppColors.oppositeColor.withOpacity(0.6),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );

  static CupertinoThemeData iosTheme = CupertinoThemeData(
    scaffoldBackgroundColor: Color(0xffffffff),
  );
}
