import 'package:flutter/material.dart';

class PlatformSheet {
  /// Opens a platform-adaptive bottom sheet.
  /// - Mobile (Android/iOS): showModalBottomSheet
  /// - Desktop/Web: bottom-aligned dialog (sheet-like)
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,

    bool isScrollControlled = true,
    bool enableDrag = true,
    bool barrierDismissible = true,
    bool useSafeArea = true,

    BorderRadius borderRadius = const BorderRadius.vertical(
      top: Radius.circular(20),
    ),
  }) async {
    if (!context.mounted) return null;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (_) => child,
    );
  }
}
