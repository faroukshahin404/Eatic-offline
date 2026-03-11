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
    return BlocBuilder<CreateOrderCubit, CreateOrderState>(
      builder: (context, state) {
        final cubit = context.read<CreateOrderCubit>();
        if (state is CreateOrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CreateOrderError) {
          return Center(child: Text(cubit.errorMessage ?? ''));
        }
        if (state is CreateOrderProductLoaded) {
          return CustomPadding(child: CreateOrderViewWidget(cubit: cubit));
        }
        return Center(child: Text('create_order.select_product_to_start'.tr()));
      },
    );
  }
}
