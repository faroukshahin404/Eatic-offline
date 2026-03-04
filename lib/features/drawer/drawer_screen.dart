import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_padding.dart';
import 'cubit/drawer_cubit.dart';
import 'widgets/drawer_list_widget.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 120,
      child: CustomPadding(
        child: BlocBuilder<DrawerCubit, DrawerState>(
          builder: (context, state) => DrawerListWidget(),
        ),
      ),
    );
  }
}
