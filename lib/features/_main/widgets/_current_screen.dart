import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/main_cubit.dart';

class CurrentScreen extends StatelessWidget {
  const CurrentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<MainCubit, MainState>(
        buildWhen:
            (previous, current) =>
                previous.runtimeType != current.runtimeType ||
                previous.customerInfoPanelVisible !=
                    current.customerInfoPanelVisible,
        builder: (context, state) {
          return context.read<MainCubit>().getCurrentScreen();
        },
      ),
    );
  }
}
