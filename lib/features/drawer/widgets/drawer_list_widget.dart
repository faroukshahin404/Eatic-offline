import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/drawer_cubit.dart';
import 'drawer_card_widget.dart';

class DrawerListWidget extends StatelessWidget {
  const DrawerListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DrawerCubit>();

    return ListView.builder(
      itemCount: cubit.drawerCards.length,
      itemBuilder: (context, index) => InkWell(
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          cubit.navigateTo(index: index);
        },
        child: DrawerCardWidget(
          drawerCard: cubit.drawerCards[index],
          isSelected: cubit.selectedDrawerCardIndex == index,
        ),
      ),
    );
  }
}
