import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cart/cubit/cart_cubit.dart';
import '../_main/cubit/main_cubit.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../routes/app_paths.dart';
import '../drawer/cubit/drawer_cubit.dart';
import './cubit/orders_status_cubit.dart';
import './widgets/orders_status_table_widget.dart';

class OrdersStatusScreen extends StatefulWidget {
  const OrdersStatusScreen({super.key});

  @override
  State<OrdersStatusScreen> createState() => _OrdersStatusScreenState();
}

class _OrdersStatusScreenState extends State<OrdersStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersStatusCubit>().loadPendingOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'orders_status.title'),
      body: CustomPadding(
        child: BlocBuilder<OrdersStatusCubit, OrdersStatusState>(
          builder: (context, state) {
            if (state is OrdersStatusLoading) {
              return const CustomLoading();
            }
            if (state is OrdersStatusError) {
              return CustomFailedWidget(
                message: state.message,
                onRetry:
                    () => context.read<OrdersStatusCubit>().loadPendingOrders(),
              );
            }

            final cubit = context.read<OrdersStatusCubit>();
            return Column(
              children: [
                Expanded(
                  child: OrdersStatusTableWidget(
                    orders: cubit.orders,

                    onUpdatePrintedStatus: (orderId, isCustomer, isKitchen) {
                      cubit.updatePrintedStatus(
                        orderId: orderId,
                        isPrintedToCustomer: isCustomer,
                        isPrintedToKitchen: isKitchen,
                      );
                    },
                    onOpenOrderInCart: (orderId) async {
                      await context.read<CartCubit>().startEditOrder(orderId);
                      if (!context.mounted) return;
                      context.read<MainCubit>().setCurrentScreen(
                        screen: AppPaths.home,
                      );
                      context.read<DrawerCubit>().changeSelectedDrawerCard(0);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
