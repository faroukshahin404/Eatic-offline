import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../create_order/create_order_screen.dart';
import '../../drawer/drawer_screen.dart';
import '../cubit/main_cubit.dart';
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
