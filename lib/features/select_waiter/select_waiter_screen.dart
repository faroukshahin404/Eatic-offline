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
import 'cubit/select_waiter_cubit.dart';
import 'widgets/waiter_list_widget.dart';

class SelectWaiterScreen extends StatelessWidget {
  const SelectWaiterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocBuilder<SelectWaiterCubit, SelectWaiterState>(
        builder: (context, state) {
          if (state is SelectWaiterLoading) {
            return const CustomLoading();
          }
          if (state is SelectWaiterError) {
            return CustomFailedWidget(
              message: state.message,
              onRetry: () => context.read<SelectWaiterCubit>().getWaiters(),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomHeaderScreen(title: 'select_waiter.title'.tr()),
              Expanded(child: const WaiterListWidget()),
              const SizedBox(height: 24),
              CustomButtonWidget(
                text: 'select_waiter.submit'.tr(),
                onPressed: () => _onSubmit(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    final selected = context.read<SelectWaiterCubit>().selectedWaiter;
    context.read<CartCubit>().setWaiter(selected);
    context.read<MainCubit>().setCurrentScreen();
  }
}
