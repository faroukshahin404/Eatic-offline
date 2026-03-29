import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../cart/cubit/cart_cubit.dart';
import '../_main/cubit/main_cubit.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../routes/app_paths.dart';
import '../drawer/cubit/drawer_cubit.dart';
import './cubit/orders_status_cubit.dart';
import './widgets/orders_status_table_widget.dart';
import './widgets/tables_grid_view_widget.dart';

class OrdersStatusScreen extends StatefulWidget {
  const OrdersStatusScreen({super.key});

  @override
  State<OrdersStatusScreen> createState() => _OrdersStatusScreenState();
}

class _OrdersStatusScreenState extends State<OrdersStatusScreen> {
  int _selectedTabIndex = 0; // 0 = Orders, 1 = Tables

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersStatusCubit>().loadPendingOrders();
    });
  }

  void _navigateToCartForEdit(int orderId) async {
    await context.read<CartCubit>().startEditOrder(orderId);
    if (!context.mounted) return;
    context.read<MainCubit>().setCurrentScreen(screen: AppPaths.home);
    context.read<DrawerCubit>().changeSelectedDrawerCard(0);
  }

  void _navigateToCartForCreate(int tableId, String? tableName) {
    final cartCubit = context.read<CartCubit>();
    cartCubit.clearCart();
    cartCubit.setOrderType(0); // dine-in
    cartCubit.setSelectedTableId(tableId);
    cartCubit.setTableNumber(tableName);
    context.read<MainCubit>().setCurrentScreen(screen: AppPaths.home);
    context.read<DrawerCubit>().changeSelectedDrawerCard(0);
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
                onRetry: () {
                  if (_selectedTabIndex == 0) {
                    context.read<OrdersStatusCubit>().loadPendingOrders();
                  } else {
                    context.read<OrdersStatusCubit>().loadTables();
                  }
                },
              );
            }

            final cubit = context.read<OrdersStatusCubit>();
            return Column(
              children: [
                const SizedBox(height: 8),
                _OrdersStatusTabs(
                  selectedIndex: _selectedTabIndex,
                  onChanged: (idx) {
                    if (idx == _selectedTabIndex) return;
                    setState(() => _selectedTabIndex = idx);
                    if (idx == 0) {
                      cubit.loadPendingOrders();
                    } else {
                      cubit.loadTables();
                    }
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _selectedTabIndex == 0
                      ? OrdersStatusTableWidget(
                          orders: cubit.orders,
                          onUpdatePrintedStatus:
                              (orderId, isCustomer, isKitchen) {
                            cubit.updatePrintedStatus(
                              orderId: orderId,
                              isPrintedToCustomer: isCustomer,
                              isPrintedToKitchen: isKitchen,
                            );
                          },
                          onOpenOrderInCart: (orderId) async {
                            _navigateToCartForEdit(orderId);
                          },
                        )
                      : TablesGridViewWidget(
                          tables: cubit.tables,
                          onFreeTableTap: (table) {
                            _navigateToCartForCreate(table.id!, table.name);
                          },
                          onOccupiedTableTap: (table) async {
                            final orderId =
                                await cubit.getPendingOrderIdByTableId(
                              table.id!,
                            );
                            if (!context.mounted) return;
                            if (orderId != null) {
                              _navigateToCartForEdit(orderId);
                            } else {
                              _navigateToCartForCreate(table.id!, table.name);
                            }
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

class _OrdersStatusTabs extends StatelessWidget {
  const _OrdersStatusTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ordersText = 'orders_status.tab_orders'.tr();
    final tablesText = 'orders_status.tab_tables'.tr();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              text: ordersText,
              icon: Icons.receipt_long,
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TabButton(
              text: tablesText,
              icon: Icons.table_restaurant,
              isSelected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(color: AppColors.greyE6E9EA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.oppositeColor,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppFonts.styleMedium16.copyWith(
                color: isSelected ? Colors.white : AppColors.oppositeColor,
                fontFamily: AppFonts.getCurrentFontFamilyBasedOnText(text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
