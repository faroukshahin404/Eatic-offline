import 'package:flutter/material.dart';

import '../../core/widgets/_adaptive_layout_widget.dart';
import '../drawer/drawer_screen.dart';
import 'widgets/desktop_main_widget.dart';
import 'widgets/mobile_main_widget.dart';
import 'widgets/tablet_main_widget.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerScreen(),
      body: AdaptiveLayoutWidget(
        mobile: (context) => const MobileMainWidget(),
        tablet: (context) => const TabletMainWidget(),
        desktop: (context) => const DesktopMainWidget(),
      ),
    );
  }
}
