import 'package:flutter/material.dart';

import '../../core/widgets/_adaptive_layout_widget.dart';
import 'widgets/desktop_home_widget.dart';
import 'widgets/mobile_home_widget.dart';
import 'widgets/tablet_home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveLayoutWidget(
        mobile: (context) => const MobileHomeWidget(),
        tablet: (context) => const TabletHomeWidget(),
        desktop: (context) => const DesktopHomeWidget(),
      ),
    );
  }
}
