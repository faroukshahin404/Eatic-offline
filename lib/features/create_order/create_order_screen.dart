import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_padding.dart';
import 'cubit/create_order_cubit.dart';
import 'cubit/create_order_state.dart';
import 'widgets/create_order_view_widget.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateOrderCubit, CreateOrderState>(
      listener: (context, state) {
        if (state is ClearProductData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('create_order.added_to_order'.tr()),
              backgroundColor: Colors.green.shade700,
            ),
          );
        } else if (state is ValidationRequested) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('create_order.select_all_variants'.tr()),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateOrderCubit>();
        if (state is CreateOrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CreateOrderError) {
          return Center(child: Text(cubit.errorMessage ?? ''));
        }
        return CustomPadding(child: CreateOrderViewWidget(cubit: cubit));
      },
    );
  }
}
