import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../routes/app_paths.dart';
import 'cubit/shifts_cubit.dart';
import 'cubit/shifts_state.dart';
import 'widgets/shifts_filter_widget.dart';
import 'widgets/shifts_table_widget.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShiftsCubit>().loadAllShifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'shifts.title'),
      body: Column(
        children: [
          const ShiftsFilterWidget(),
          Expanded(
            child: BlocBuilder<ShiftsCubit, ShiftsState>(
              builder: (context, state) {
                if (state is ShiftsLoading) return const CustomLoading();
                if (state is ShiftsError) {
                  return CustomFailedWidget(
                    message: state.message,
                    onRetry: () => context.read<ShiftsCubit>().loadAllShifts(),
                  );
                }
                if (state is ShiftsLoaded) {
                  return ShiftsTableWidget(
                    custodies: state.custodies,
                    onShow:
                        (custody) {
                          context.push(AppPaths.allCurrencies, extra: custody.id);
                        },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
