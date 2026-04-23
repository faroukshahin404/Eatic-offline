import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/app_utils.dart';
import '../features/_main/main_screen.dart';
import '../features/add_new_branch/add_new_branch_screen.dart';
import '../features/add_new_branch/cubit/add_new_branch_cubit.dart';
import '../features/add_new_delivery/cubit/add_new_delivery_cubit.dart';
import '../features/add_users/add_user_screen.dart';
import '../features/add_users/cubit/add_user_cubit.dart';
import '../features/branches/branches_screen.dart';
import '../features/branches/cubit/branches_cubit.dart';
import '../features/add_new_delivery/add_new_delivery_screen.dart';
import '../features/deliveries/cubit/delivery_men_cubit.dart';
import '../features/deliveries/delivery_men_screen.dart';
import '../features/login/cubit/login_cubit.dart';
import '../features/add_new_currency/add_new_currency_screen.dart';
import '../features/add_new_zone/add_new_zone_screen.dart';
import '../features/currencies/cubit/currencies_cubit.dart';
import '../features/currencies/currencies_screen.dart';
import '../features/payment_methods/cubit/payment_methods_cubit.dart';
import '../features/payment_methods/payment_methods_screen.dart';
import '../features/dining_areas/cubit/dining_areas_cubit.dart';
import '../features/dining_areas/dining_areas_screen.dart';
import '../features/restaurant_tables/cubit/restaurant_tables_cubit.dart';
import '../features/restaurant_tables/restaurant_tables_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/categories/cubit/categories_cubit.dart';
import '../features/addons/cubit/addons_cubit.dart';
import '../features/addons/addons_screen.dart';
import '../features/price_lists/cubit/price_lists_cubit.dart';
import '../features/price_lists/price_lists_screen.dart';
import '../features/add_new_product/add_new_product_screen.dart';
import '../features/add_new_product/cubit/add_new_product_cubit.dart';
import '../features/products/products_screen.dart';
import '../features/shift_details/cubit/shift_details_cubit.dart';
import '../features/shift_details/shift_details_screen.dart';
import '../features/zones/cubit/zones_cubit.dart';
import '../features/zones/zones_screen.dart';
import '../features/login/login_screen.dart';
import '../features/installation/cubit/installation_cubit.dart';
import '../features/installation/installation_screen.dart';
import '../features/installation/setup_screen.dart';
import '../features/installation/syncing_screen.dart';
import '../features/reset_password/cubit/reset_password_cubit.dart';
import '../features/reset_password/reset_password_screen.dart';
import '../features/setting/setting_screen.dart';
import '../features/general_settings/general_settings_screen.dart';
import '../features/splash_screen.dart';
import '../features/select_waiter/select_waiter_screen.dart';
import '../features/select_waiter/cubit/select_waiter_cubit.dart';
import '../features/select_table/select_table_screen.dart';
import '../features/select_table/cubit/select_table_cubit.dart';
import '../features/add_customers/add_customer_screen.dart';
import '../features/add_customers/cubit/add_customer_cubit.dart';
import '../features/customers/customer_search_screen.dart';
import '../features/customers/cubit/customer_search_cubit.dart';
import '../features/users/cubit/users_cubit.dart';
import '../features/users/users_screen.dart';
import '../services_locator/service_locator.dart';
import 'app_paths.dart';
import 'app_route_transitions.dart';

GoRoute _appRoute({
  required String path,
  required Widget Function(BuildContext context, GoRouterState state) builder,
  bool fadeOnly = false,
}) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) {
      final child = builder(context, state);
      return fadeOnly
          ? AppRouteTransitions.fade(state, child)
          : AppRouteTransitions.modal(state, child);
    },
  );
}

final myObserver = MyRouteObserver();

class MyRouteObserver extends NavigatorObserver {
  final List<String> visited = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    final name = route.settings.name;
    if (name != null && !visited.contains(name)) {
      visited.add(name);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final name = route.settings.name;
    if (name != null && visited.contains(name)) {
      visited.remove(name);
    }
    super.didPop(route, previousRoute);
  }
}

class AppPages {
  static final router = GoRouter(
    navigatorKey: AppUtils.navigatorKey,
    initialLocation: AppPaths.splash,
    observers: [myObserver],
    routes: [
      _appRoute(
        path: AppPaths.splash,
        fadeOnly: true,
        builder: (context, state) => const SplashScreen(),
      ),

      _appRoute(
        path: AppPaths.main,
        builder: (context, state) => const MainScreen(),
      ),

      _appRoute(
        path: AppPaths.installation,
        builder:
            (context, state) => BlocProvider<InstallationCubit>(
              create: (context) => getIt<InstallationCubit>(),
              child: const InstallationScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.setup,
        builder: (context, state) => const SetupScreen(),
      ),

      _appRoute(
        path: AppPaths.syncing,
        builder: (context, state) => const SyncingScreen(),
      ),

      _appRoute(
        path: AppPaths.login,
        builder:
            (context, state) => BlocProvider<LoginCubit>(
              create: (context) => getIt<LoginCubit>(),
              child: const LoginScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.settings,
        builder: (context, state) => SettingScreen(),
      ),

      _appRoute(
        path: AppPaths.generalSettings,
        builder: (context, state) => const GeneralSettingsScreen(),
      ),

      _appRoute(
        path: AppPaths.users,
        builder:
            (context, state) => BlocProvider<UsersCubit>(
              create: (context) => getIt<UsersCubit>()..getUsers(),
              child: UsersScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.addUser,
        builder:
            (context, state) => BlocProvider<AddUserCubit>(
              create:
                  (context) =>
                      getIt<AddUserCubit>()..getRoles(id: state.extra as int?),
              child: AddUserScreen(userId: state.extra as int?),
            ),
      ),

      _appRoute(
        path: AppPaths.addBranch,
        builder:
            (context, state) => BlocProvider<AddNewBranchCubit>(
              create: (context) => getIt<AddNewBranchCubit>(),
              child: const AddNewBranchScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.branches,
        builder:
            (context, state) => BlocProvider<BranchesCubit>(
              create: (context) => getIt<BranchesCubit>()..getBranches(),
              child: BranchesScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.deliveryMen,
        builder:
            (context, state) => BlocProvider<DeliveryMenCubit>(
              create: (context) => getIt<DeliveryMenCubit>()..getAll(),
              child: const DeliveryMenScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.addDelivery,
        builder:
            (context, state) => BlocProvider<AddNewDeliveryCubit>(
              create: (context) {
                final cubit = getIt<AddNewDeliveryCubit>();
                if (state.extra != null) {
                  cubit.setDeliveryIdForEdit(state.extra as int);
                }
                cubit.loadBranches();
                return cubit;
              },
              child: AddNewDeliveryScreen(deliveryId: state.extra as int?),
            ),
      ),

      _appRoute(
        path: AppPaths.zones,
        builder:
            (context, state) => BlocProvider<ZonesCubit>(
              create: (context) => getIt<ZonesCubit>()..getAllZones(),
              child: const ZonesScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.addZone,
        builder:
            (context, state) => AddNewZoneScreen(zoneId: state.extra as int?),
      ),

      _appRoute(
        path: AppPaths.currencies,
        builder:
            (context, state) => BlocProvider<CurrenciesCubit>(
              create: (context) => getIt<CurrenciesCubit>()..getAll(),
              child: const CurrenciesScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.addCurrency,
        builder:
            (context, state) =>
                AddNewCurrencyScreen(currencyId: state.extra as int?),
      ),

      _appRoute(
        path: AppPaths.paymentMethods,
        builder:
            (context, state) => BlocProvider<PaymentMethodsCubit>(
              create: (context) => getIt<PaymentMethodsCubit>()..getAll(),
              child: const PaymentMethodsScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.diningAreas,
        builder:
            (context, state) => BlocProvider<DiningAreasCubit>(
              create: (context) => getIt<DiningAreasCubit>()..getAll(),
              child: const DiningAreasScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.restaurantTables,
        builder:
            (context, state) => BlocProvider<RestaurantTablesCubit>(
              create: (context) => getIt<RestaurantTablesCubit>()..getAll(),
              child: const RestaurantTablesScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.categories,
        builder:
            (context, state) => BlocProvider<CategoriesCubit>(
              create: (context) => getIt<CategoriesCubit>()..getAll(),
              child: const CategoriesScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.addons,
        builder:
            (context, state) => BlocProvider<AddonsCubit>(
              create: (context) => getIt<AddonsCubit>()..getAll(),
              child: const AddonsScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.priceLists,
        builder:
            (context, state) => BlocProvider<PriceListsCubit>(
              create: (context) => getIt<PriceListsCubit>()..getAll(),
              child: const PriceListsScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.addProduct,
        builder:
            (context, state) => BlocProvider<AddNewProductCubit>(
              create:
                  (context) =>
                      getIt<AddNewProductCubit>()
                        ..loadData(productId: state.extra as int?),
              child: const AddNewProductScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.products,
        builder: (context, state) => const ProductsScreen(),
      ),

      // GoRoute(
      //   path: AppPaths.createOrder,
      //   builder: (context, state) => BlocProvider<CreateOrderCubit>(
      //     create: (context) =>
      //         getIt<CreateOrderCubit>()..loadProductById(state.extra as int),
      //     child: const CreateOrderScreen(),
      //   ),
      // ),
      _appRoute(
        path: AppPaths.selectWaiter,
        builder:
            (context, state) => BlocProvider<SelectWaiterCubit>(
              create: (context) => getIt<SelectWaiterCubit>()..getWaiters(),
              child: const SelectWaiterScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.selectTable,
        builder:
            (context, state) => BlocProvider<SelectTableCubit>(
              create: (context) => getIt<SelectTableCubit>()..loadTables(),
              child: const SelectTableScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.customerSearch,
        builder:
            (context, state) => BlocProvider<CustomerSearchCubit>(
              create: (context) => getIt<CustomerSearchCubit>(),
              child: const CustomerSearchScreen(),
            ),
      ),

      _appRoute(
        path: AppPaths.addCustomer,
        builder:
            (context, state) => BlocProvider<AddCustomerCubit>(
              create: (context) {
                return getIt<AddCustomerCubit>()
                  ..loadZones(customerId: state.extra as int?);
              },
              child: const AddCustomerScreen(),
            ),
      ),
      _appRoute(
        path: AppPaths.resetPassword,
        builder:
            (context, state) => BlocProvider<ResetPasswordCubit>(
              create: (context) => getIt<ResetPasswordCubit>(),
              child: const ResetPasswordScreen(),
            ),
      ),
      _appRoute(
        path: AppPaths.allCurrencies,
        builder:
            (context, state) => BlocProvider<ShiftDetailsCubit>(
              create:
                  (context) =>
                      getIt<ShiftDetailsCubit>()
                        ..loadReport(custodyId: state.extra as int),
              child: const ShiftDetailsScreen(),
            ),
      ),
      _appRoute(
        path: AppPaths.shiftDetails,
        builder:
            (context, state) => BlocProvider<ShiftDetailsCubit>(
              create:
                  (context) =>
                      getIt<ShiftDetailsCubit>()
                        ..loadReport(custodyId: state.extra as int),
              child: const ShiftDetailsScreen(),
            ),
      ),
    ],
  );
}
