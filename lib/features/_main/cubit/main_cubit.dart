import 'dart:developer';

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
import '../../select_waiter/cubit/select_waiter_cubit.dart';
import '../../select_waiter/select_waiter_screen.dart';
import '../../select_table/cubit/select_table_cubit.dart';
import '../../select_table/select_table_screen.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitial());

  String currentScreen = AppPaths.home;
  dynamic data;

  void setCurrentScreen({String? screen, dynamic data}) {
    if (screen == currentScreen) return;
    emit(MainInitial());

    currentScreen = screen ?? AppPaths.home;
    this.data = data;
    emit(MainScreenChanged());
  }

  Widget getCurrentScreen() {
    switch (currentScreen) {
      case AppPaths.home:
        return const HomeScreen();
      case AppPaths.cart:
        return const CartScreen();
      case AppPaths.createOrder:
        return BlocProvider<CreateOrderCubit>(
          create: (context) =>
              getIt<CreateOrderCubit>()..loadProductById(data as int),
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
            log(data.toString());
            return getIt<AddCustomerCubit>()
              ..loadZones(customerId: data as int?);
          },
          child: const AddCustomerScreen(),
        );
      default:
        return const HomeScreen();
    }
  }
}
