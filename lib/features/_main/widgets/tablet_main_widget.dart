import 'package:flutter/material.dart';

import '../../drawer/drawer_screen.dart';
import '_current_screen.dart';

class TabletMainWidget extends StatelessWidget {
  const TabletMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DrawerScreen(),
        Expanded(child: CurrentScreen()),
        // CreateOrderScreen(),
      ],
    );
  }
}
