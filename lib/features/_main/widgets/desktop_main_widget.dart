import 'package:flutter/material.dart';

import '../../create_order/create_order_screen.dart';
import '../../drawer/drawer_screen.dart';
import '_current_screen.dart';

class DesktopMainWidget extends StatelessWidget {
  const DesktopMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DrawerScreen(),
        Expanded(child: CurrentScreen()),
        CreateOrderScreen(),
      ],
    );
  }
}
