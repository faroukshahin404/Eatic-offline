import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/drawer_cubit.dart';
import 'widgets/drawer_list_widget.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 120,
      backgroundColor: Color(0xffffffff),
      shadowColor: Colors.transparent,
      shape: Border(
        right: BorderSide(color: AppColors.greyE6E9EA),
        bottom: BorderSide(color: AppColors.greyE6E9EA),
        left: BorderSide(color: AppColors.greyE6E9EA),
      ),
      child: CustomPadding(
        child: BlocBuilder<DrawerCubit, DrawerState>(
          builder: (context, state) => DrawerListWidget(),
        ),
      ),
    );
  }
}
