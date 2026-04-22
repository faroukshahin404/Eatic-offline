import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../routes/app_paths.dart';
import '../../../services_locator/service_locator.dart';
import '../../add_customers/add_customer_screen.dart';
import '../../add_customers/cubit/add_customer_cubit.dart';
import '../../cart/cart_screen.dart';
import '../../create_order/create_order_screen.dart';
import '../../create_order/cubit/create_order_cubit.dart';
import '../../customers/cubit/customer_search_cubit.dart';
import '../../customers/customer_search_screen.dart';
import '../../home/home_screen.dart';
import '../../orders_status/cubit/orders_status_cubit.dart';
import '../../orders_status/orders_status_screen.dart';
import '../../select_waiter/cubit/select_waiter_cubit.dart';
import '../../select_waiter/select_waiter_screen.dart';
import '../../select_table/cubit/select_table_cubit.dart';
import '../../select_table/select_table_screen.dart';
import '../../shifts/cubit/shifts_cubit.dart';
import '../../shifts/shifts_screen.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(const MainInitial(customerInfoPanelVisible: false));

  String currentScreen = AppPaths.home;
  dynamic data;
  bool customerInfoPanelVisible = false;

  void setCurrentScreen({String? screen, dynamic data}) {
    if (screen == currentScreen) return;
    emit(MainInitial(customerInfoPanelVisible: customerInfoPanelVisible));

    currentScreen = screen ?? AppPaths.home;
    this.data = data;
    emit(MainScreenChanged(customerInfoPanelVisible: customerInfoPanelVisible));
  }

  void toggleCustomerInfoPanel() {
    customerInfoPanelVisible = !customerInfoPanelVisible;
    emit(
      MainCustomerInfoPanelChanged(
        customerInfoPanelVisible: customerInfoPanelVisible,
      ),
    );
  }

  void setCustomerInfoPanelVisible(bool visible) {
    if (customerInfoPanelVisible == visible) return;
    customerInfoPanelVisible = visible;
    emit(
      MainCustomerInfoPanelChanged(
        customerInfoPanelVisible: customerInfoPanelVisible,
      ),
    );
  }

  Widget getCurrentScreen() {
    switch (currentScreen) {
      case AppPaths.home:
        return const HomeScreen();
      case AppPaths.cart:
        return const CartScreen();
      case AppPaths.createOrder:
        return BlocProvider<CreateOrderCubit>(
          create: (context) {
            final payload = data;
            int? productId;
            int? priceListId;
            if (payload is int) {
              productId = payload;
            } else if (payload is Map<String, dynamic>) {
              final p = payload['productId'];
              final pl = payload['priceListId'];
              if (p is int) productId = p;
              if (pl is int) priceListId = pl;
            }
            final cubit = getIt<CreateOrderCubit>();
            cubit.setSelectedPriceListId(priceListId);
            if (productId != null) {
              cubit.loadProductById(productId);
            }
            return cubit;
          },
          child: CreateOrderScreen(),
        );
      case AppPaths.selectWaiter:
        return BlocProvider<SelectWaiterCubit>(
          create: (context) => getIt<SelectWaiterCubit>()..getWaiters(),
          child: const SelectWaiterScreen(),
        );
      case AppPaths.selectTable:
        return BlocProvider<SelectTableCubit>(
          create: (context) => getIt<SelectTableCubit>()..loadTables(),
          child: const SelectTableScreen(),
        );
      case AppPaths.customerSearch:
        return BlocProvider<CustomerSearchCubit>(
          create: (context) => getIt<CustomerSearchCubit>(),
          child: const CustomerSearchScreen(),
        );
      case AppPaths.addCustomer:
        return BlocProvider<AddCustomerCubit>(
          create: (context) {
            return getIt<AddCustomerCubit>()
              ..loadZones(customerId: data as int?);
          },
          child: const AddCustomerScreen(),
        );
      case AppPaths.shifts:
        return BlocProvider<ShiftsCubit>(
          create: (_) => getIt<ShiftsCubit>(),
          child: const ShiftsScreen(),
        );
      case AppPaths.ordersStatus:
        return BlocProvider<OrdersStatusCubit>(
          create: (_) => getIt<OrdersStatusCubit>(),
          child: const OrdersStatusScreen(),
        );
      default:
        return const HomeScreen();
    }
  }
}
