import 'package:flutter/material.dart';

class AdaptiveLayoutWidget extends StatelessWidget {
  const AdaptiveLayoutWidget({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 900,
  });

  final WidgetBuilder mobile, tablet, desktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        final w = constraints.maxWidth;
        if (w < mobileBreakpoint) return mobile(layoutContext);
        if (w < tabletBreakpoint) return tablet(layoutContext);
        return desktop(layoutContext);
      },
    );
  }
}
