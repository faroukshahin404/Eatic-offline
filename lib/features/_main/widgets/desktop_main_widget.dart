import 'package:flutter/material.dart';

import '../../cart/cart_screen.dart';
import '../../drawer/drawer_screen.dart';
import '_current_screen.dart';

class DesktopMainWidget extends StatelessWidget {
  const DesktopMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DrawerScreen(),
        Expanded(flex: 2, child: CurrentScreen()),
        Expanded(child: CartScreen()),
      ],
    );
  }
}
