import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_utils.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import 'cubit/cart_cubit.dart';
import 'cubit/cart_state.dart';
import 'widgets/cart_footer/_cart_footer.dart';
import 'widgets/cart_header.dart';
import 'widgets/cart_order_type_selector.dart';
import 'widgets/cart_scrollable_content.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>()
      ..loadOrderTypes()
      ..refreshHasOpenCustody()
      ..loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.screenState == ScreenState.loading) {
          return const CustomLoading();
        }
        if (state.screenState == ScreenState.error) {
          return CustomFailedWidget(
            message: 'Error loading order types',
            onRetry: () => context.read<CartCubit>().loadOrderTypes(),
          );
        }
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.greyE6E9EA),
            ),
            child: Column(
              spacing: 16,
              children: [
                const CartHeader(),
                const CartOrderTypeSelector(),
                const Expanded(child: CartScrollableContent()),
                const CartFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
