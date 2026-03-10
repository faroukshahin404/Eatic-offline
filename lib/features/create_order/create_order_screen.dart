import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import 'cubit/create_order_cubit.dart';
import 'cubit/create_order_state.dart';
import 'widgets/create_order_addons_section.dart';
import 'widgets/create_order_variants_section.dart';
import 'widgets/order_product_card.dart';
import 'widgets/price_list_dropdown.dart';

class CreateOrderScreen extends StatelessWidget {
  final int productId;
  const CreateOrderScreen({super.key, required this.productId});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateOrderCubit>(
      create: (context) =>
          getIt<CreateOrderCubit>()..loadProductById(productId),
      child: BlocBuilder<CreateOrderCubit, CreateOrderState>(
        builder: (context, state) {
          final cubit = context.read<CreateOrderCubit>();
          if (state is CreateOrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CreateOrderError) {
            return Center(child: Text(cubit.errorMessage ?? ''));
          }
          if (state is CreateOrderProductLoaded) {
            return CustomPadding(
              child: ListView(
                children: [
                  OrderProductCard(),
                  const SizedBox(height: 16),
                  PriceListDropdown(cubit: cubit),

                  const SizedBox(height: 16),
                  CreateOrderVariantsSection(cubit: cubit),
                  const SizedBox(height: 16),
                  CreateOrderAddonsSection(cubit: cubit),
                ],
              ),
            );
          }
          return Center(
            child: Text('create_order.select_product_to_start'.tr()),
          );
        },
      ),
    );
  }
}
