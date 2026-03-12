import 'package:flutter/material.dart';

import '../../../core/widgets/custom_app_bar.dart';
import '../../cart/cart_screen.dart';
import '../../drawer/drawer_screen.dart';
import '_current_screen.dart';

class DesktopMainWidget extends StatelessWidget {
  const DesktopMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: CartScreen()),

        Expanded(
          flex: 3,
          child: Column(
            children: [
              CustomAppBar(title: "Eatic"),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 2, child: CurrentScreen()),
                    DrawerScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
