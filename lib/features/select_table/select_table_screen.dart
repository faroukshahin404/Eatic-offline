import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_header_screen.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../_main/cubit/main_cubit.dart';
import '../cart/cubit/cart_cubit.dart';
import 'cubit/select_table_cubit.dart';
import 'widgets/table_grid_widget.dart';

class SelectTableScreen extends StatelessWidget {
  const SelectTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocBuilder<SelectTableCubit, SelectTableState>(
        builder: (context, state) {
          if (state is SelectTableLoading) {
            return const CustomLoading();
          }
          if (state is SelectTableError) {
            return CustomFailedWidget(
              message: state.message,
              onRetry: () => context.read<SelectTableCubit>().loadTables(),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomHeaderScreen(title: 'cart.choose_table'.tr()),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(child: const TableGridWidget()),
              ),
              const SizedBox(height: 24),
              CustomButtonWidget(
                text: 'select_table.submit'.tr(),
                onPressed: () => _onSubmit(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    final selected = context.read<SelectTableCubit>().selectedTable;
    final cartCubit = context.read<CartCubit>();
    cartCubit.setTableNumber(
      selected?.name ?? selected?.id?.toString(),
    );
    cartCubit.setSelectedTableId(selected?.id);
    context.read<MainCubit>().setCurrentScreen();
  }
}
