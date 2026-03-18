import 'package:get_it/get_it.dart';

import '../core/data/sqLite/database_service.dart';
import '../features/_main/cubit/main_cubit.dart';
import '../features/add_new_branch/cubit/add_new_branch_cubit.dart';
import '../features/add_new_branch/repos/offline/add_new_branch_offline_repos.dart';
import '../features/add_users/cubit/add_user_cubit.dart';
import '../features/add_users/repos/offline/add_user_offline_repos.dart';
import '../features/branches/cubit/branches_cubit.dart';
import '../features/select_waiter/cubit/select_waiter_cubit.dart';
import '../features/select_table/cubit/select_table_cubit.dart';
import '../features/add_customers/cubit/add_customer_cubit.dart';
import '../features/add_customers/repos/offline/add_customers_offline_repos.dart';
import '../features/customers/cubit/customer_search_cubit.dart';
import '../features/customers/repos/offline/customers_offline_repos.dart';
import '../features/branches/repos/offline/branches_offline_repos.dart';
import '../features/add_new_delivery/cubit/add_new_delivery_cubit.dart';
import '../features/add_new_delivery/repos/offline/add_new_delivery_offline_repos.dart';
import '../features/deliveries/cubit/delivery_men_cubit.dart';
import '../features/deliveries/repos/offline/deliveries_offline_repos.dart';
import '../features/drawer/cubit/drawer_cubit.dart';
import '../features/shifts/cubit/shifts_cubit.dart';
import '../features/home/cubit/home_cubit.dart';
import '../features/add_new_zone/cubit/add_new_zone_cubit.dart';
import '../features/add_new_zone/repos/offline/add_new_zone_offline_repos.dart';
import '../features/add_new_currency/cubit/add_new_currency_cubit.dart';
import '../features/add_new_currency/repos/offline/add_new_currency_offline_repos.dart';
import '../features/currencies/cubit/currencies_cubit.dart';
import '../features/currencies/repos/offline/currencies_offline_repos.dart';
import '../features/add_new_payment_method/cubit/add_new_payment_method_cubit.dart';
import '../features/add_new_payment_method/repos/offline/add_new_payment_method_offline_repos.dart';
import '../features/payment_methods/cubit/payment_methods_cubit.dart';
import '../features/payment_methods/repos/offline/payment_methods_offline_repos.dart';
import '../features/add_new_dining_area/cubit/add_new_dining_area_cubit.dart';
import '../features/add_new_dining_area/repos/offline/add_new_dining_area_offline_repos.dart';
import '../features/dining_areas/cubit/dining_areas_cubit.dart';
import '../features/dining_areas/repos/offline/dining_areas_offline_repos.dart';
import '../features/add_new_restaurant_table/cubit/add_new_restaurant_table_cubit.dart';
import '../features/add_new_restaurant_table/repos/offline/add_new_restaurant_table_offline_repos.dart';
import '../features/restaurant_tables/cubit/restaurant_tables_cubit.dart';
import '../features/restaurant_tables/repos/offline/restaurant_tables_offline_repos.dart';
import '../features/categories/cubit/categories_cubit.dart';
import '../features/categories/repos/offline/categories_offline_repos.dart';
import '../features/add_new_category/cubit/add_new_category_cubit.dart';
import '../features/add_new_category/repos/offline/add_new_category_offline_repos.dart';
import '../features/addons/cubit/addons_cubit.dart';
import '../features/addons/repos/offline/addons_offline_repos.dart';
import '../features/add_new_addon/cubit/add_new_addon_cubit.dart';
import '../features/add_new_addon/repos/offline/add_new_addon_offline_repos.dart';
import '../features/add_new_price_list/cubit/add_new_price_list_cubit.dart';
import '../features/add_new_price_list/repos/offline/add_new_price_list_offline_repos.dart';
import '../features/price_lists/cubit/price_lists_cubit.dart';
import '../features/price_lists/repos/offline/price_lists_offline_repos.dart';
import '../features/add_new_product/cubit/add_new_product_cubit.dart';
import '../features/add_new_product/repos/offline/add_new_product_offline_repos.dart';
import '../features/products/cubit/products_cubit.dart';
import '../features/products/repos/offline/products_offline_repos.dart';
import '../features/create_order/cubit/create_order_cubit.dart';
import '../features/create_order/repos/offline/create_order_offline_repos.dart';
import '../features/cart/cubit/cart_cubit.dart';
import '../features/custody/cubit/custody_cubit.dart';
import '../features/custody/repos/offline/custody_offline_repos.dart';
import '../features/cart/orders/repos/offline/orders_offline_repos.dart';
import '../features/zones/cubit/zones_cubit.dart';
import '../features/zones/repos/offline/zones_offline_repos.dart';
import '../features/login/cubit/login_cubit.dart';
import '../features/login/repos/offline/login_offline_repos.dart';
import '../features/reset_password/cubit/reset_password_cubit.dart';
import '../features/reset_password/repos/offline/reset_password_offline_repos.dart';
import '../features/users/cubit/users_cubit.dart';
import '../features/users/repos/offline/user_offline_repos.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  getIt.registerSingleton<DatabaseService>(DatabaseService());
  getIt.registerSingleton<DrawerCubit>(DrawerCubit());
  getIt.registerSingleton<MainCubit>(MainCubit());

  getIt.registerLazySingleton<UserOfflineRepository>(
    () => UsersOfflineRepoImpl(),
  );
  getIt.registerFactory<UsersCubit>(
    () => UsersCubit(getIt<UserOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddUserOfflineRepository>(
    () => AddUserOfflineRepoImpl(),
  );
  getIt.registerFactory<AddUserCubit>(
    () => AddUserCubit(
      getIt<AddUserOfflineRepository>(),
      getIt<BranchesOfflineRepository>(),
    ),
  );

  getIt.registerFactory<SelectWaiterCubit>(
    () => SelectWaiterCubit(getIt<UserOfflineRepository>()),
  );

  getIt.registerFactory<SelectTableCubit>(
    () => SelectTableCubit(getIt<RestaurantTablesOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddCustomersOfflineRepository>(
    () => AddCustomersOfflineRepoImpl(),
  );
  getIt.registerFactory<AddCustomerCubit>(
    () => AddCustomerCubit(
      getIt<AddCustomersOfflineRepository>(),
      getIt<ZonesOfflineRepository>(),
    ),
  );
  getIt.registerLazySingleton<CustomersOfflineRepository>(
    () => CustomersOfflineRepoImpl(),
  );
  getIt.registerFactory<CustomerSearchCubit>(
    () => CustomerSearchCubit(getIt<CustomersOfflineRepository>()),
  );

  getIt.registerLazySingleton<LoginOfflineRepository>(
    () => LoginOfflineRepoImpl(),
  );
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(getIt<LoginOfflineRepository>()),
  );

  getIt.registerLazySingleton<ResetPasswordOfflineRepository>(
    () => ResetPasswordOfflineRepoImpl(),
  );
  getIt.registerFactory<ResetPasswordCubit>(
    () => ResetPasswordCubit(getIt<ResetPasswordOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddNewBranchOfflineRepository>(
    () => AddNewBranchOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewBranchCubit>(
    () => AddNewBranchCubit(getIt<AddNewBranchOfflineRepository>()),
  );
  getIt.registerFactory<BranchesCubit>(
    () => BranchesCubit(getIt<BranchesOfflineRepository>()),
  );

  getIt.registerLazySingleton<BranchesOfflineRepository>(
    () => BranchesOfflineRepoImpl(),
  );

  getIt.registerLazySingleton<DeliveriesOfflineRepository>(
    () => DeliveriesOfflineRepoImpl(),
  );
  getIt.registerFactory<DeliveryMenCubit>(
    () => DeliveryMenCubit(getIt<DeliveriesOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddNewDeliveryOfflineRepository>(
    () => AddNewDeliveryOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewDeliveryCubit>(
    () => AddNewDeliveryCubit(
      getIt<BranchesOfflineRepository>(),
      getIt<AddNewDeliveryOfflineRepository>(),
    ),
  );

  getIt.registerLazySingleton<ZonesOfflineRepository>(
    () => ZonesOfflineRepoImpl(),
  );
  getIt.registerFactory<ZonesCubit>(
    () => ZonesCubit(getIt<ZonesOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddNewZoneOfflineRepository>(
    () => AddNewZoneOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewZoneCubit>(
    () => AddNewZoneCubit(
      getIt<BranchesOfflineRepository>(),
      getIt<AddNewZoneOfflineRepository>(),
    ),
  );

  getIt.registerLazySingleton<CurrenciesOfflineRepository>(
    () => CurrenciesOfflineRepoImpl(),
  );
  getIt.registerFactory<CurrenciesCubit>(
    () => CurrenciesCubit(getIt<CurrenciesOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddNewCurrencyOfflineRepository>(
    () => AddNewCurrencyOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewCurrencyCubit>(
    () => AddNewCurrencyCubit(getIt<AddNewCurrencyOfflineRepository>()),
  );

  getIt.registerLazySingleton<PaymentMethodsOfflineRepository>(
    () => PaymentMethodsOfflineRepoImpl(),
  );
  getIt.registerFactory<PaymentMethodsCubit>(
    () => PaymentMethodsCubit(getIt<PaymentMethodsOfflineRepository>()),
  );

  getIt.registerLazySingleton<DiningAreasOfflineRepository>(
    () => DiningAreasOfflineRepoImpl(),
  );
  getIt.registerFactory<DiningAreasCubit>(
    () => DiningAreasCubit(getIt<DiningAreasOfflineRepository>()),
  );

  getIt.registerLazySingleton<RestaurantTablesOfflineRepository>(
    () => RestaurantTablesOfflineRepoImpl(),
  );
  getIt.registerFactory<RestaurantTablesCubit>(
    () => RestaurantTablesCubit(getIt<RestaurantTablesOfflineRepository>()),
  );

  getIt.registerLazySingleton<CategoriesOfflineRepository>(
    () => CategoriesOfflineRepoImpl(),
  );
  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(getIt<CategoriesOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddNewCategoryOfflineRepository>(
    () => AddNewCategoryOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewCategoryCubit>(
    () => AddNewCategoryCubit(
      getIt<CategoriesOfflineRepository>(),
      getIt<AddNewCategoryOfflineRepository>(),
    ),
  );

  getIt.registerLazySingleton<AddonsOfflineRepository>(
    () => AddonsOfflineRepoImpl(),
  );
  getIt.registerFactory<AddonsCubit>(
    () => AddonsCubit(getIt<AddonsOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddNewAddonOfflineRepository>(
    () => AddNewAddonOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewAddonCubit>(
    () => AddNewAddonCubit(getIt<AddNewAddonOfflineRepository>()),
  );

  getIt.registerLazySingleton<PriceListsOfflineRepository>(
    () => PriceListsOfflineRepoImpl(),
  );
  getIt.registerFactory<PriceListsCubit>(
    () => PriceListsCubit(getIt<PriceListsOfflineRepository>()),
  );

  getIt.registerLazySingleton<AddNewPriceListOfflineRepository>(
    () => AddNewPriceListOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewPriceListCubit>(
    () => AddNewPriceListCubit(
      getIt<CurrenciesOfflineRepository>(),
      getIt<AddNewPriceListOfflineRepository>(),
    ),
  );

  getIt.registerLazySingleton<AddNewProductOfflineRepository>(
    () => AddNewProductOfflineRepoImpl(),
  );
  getIt.registerLazySingleton<ProductsOfflineRepository>(
    () => ProductsOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewProductCubit>(
    () => AddNewProductCubit(
      getIt<CategoriesOfflineRepository>(),
      getIt<AddonsOfflineRepository>(),
      getIt<PriceListsOfflineRepository>(),
      getIt<AddNewProductOfflineRepository>(),
    ),
  );

  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(getIt<ProductsOfflineRepository>()),
  );

  getIt.registerLazySingleton<CreateOrderOfflineRepository>(
    () => CreateOrderOfflineRepoImpl(),
  );
  getIt.registerFactory<CreateOrderCubit>(
    () => CreateOrderCubit(
      getIt<CreateOrderOfflineRepository>(),
      getIt<PriceListsOfflineRepository>(),
    ),
  );

  getIt.registerLazySingleton<CustodyOfflineRepository>(
    () => CustodyOfflineRepoImpl(),
  );
  getIt.registerFactory<CustodyCubit>(
    () => CustodyCubit(getIt<CustodyOfflineRepository>()),
  );

  getIt.registerFactory<ShiftsCubit>(
    () => ShiftsCubit(getIt<CustodyOfflineRepository>()),
  );

  getIt.registerLazySingleton<OrdersOfflineRepository>(
    () => OrdersOfflineRepoImpl(),
  );
  getIt.registerFactory<CartCubit>(
    () => CartCubit(
      getIt<CustodyOfflineRepository>(),
      getIt<OrdersOfflineRepository>(),
      getIt<PaymentMethodsOfflineRepository>(),
      getIt<RestaurantTablesOfflineRepository>(),
    ),
  );

  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      getIt<CategoriesOfflineRepository>(),
      getIt<ProductsOfflineRepository>(),
    ),
  );

  getIt.registerLazySingleton<AddNewRestaurantTableOfflineRepository>(
    () => AddNewRestaurantTableOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewRestaurantTableCubit>(
    () => AddNewRestaurantTableCubit(
      getIt<BranchesOfflineRepository>(),
      getIt<DiningAreasOfflineRepository>(),
      getIt<AddNewRestaurantTableOfflineRepository>(),
    ),
  );

  getIt.registerLazySingleton<AddNewDiningAreaOfflineRepository>(
    () => AddNewDiningAreaOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewDiningAreaCubit>(
    () => AddNewDiningAreaCubit(
      getIt<BranchesOfflineRepository>(),
      getIt<AddNewDiningAreaOfflineRepository>(),
    ),
  );

  getIt.registerLazySingleton<AddNewPaymentMethodOfflineRepository>(
    () => AddNewPaymentMethodOfflineRepoImpl(),
  );
  getIt.registerFactory<AddNewPaymentMethodCubit>(
    () =>
        AddNewPaymentMethodCubit(getIt<AddNewPaymentMethodOfflineRepository>()),
  );
}
