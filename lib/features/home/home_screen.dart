import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/_adaptive_layout_widget.dart';
import '../../services_locator/service_locator.dart';
import 'cubit/home_cubit.dart';
import 'widgets/desktop_home_widget.dart';
import 'widgets/mobile_home_widget.dart';
import 'widgets/tablet_home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fillColor,
      body: BlocProvider<HomeCubit>(
        create: (context) => getIt<HomeCubit>()..loadData(),
        child: AdaptiveLayoutWidget(
          mobile: (context) => const MobileHomeWidget(),
          tablet: (context) => const TabletHomeWidget(),
          desktop: (context) => const DesktopHomeWidget(),
        ),
      ),
    );
  }
}
