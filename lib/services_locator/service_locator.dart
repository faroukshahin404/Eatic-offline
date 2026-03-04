import 'package:get_it/get_it.dart';

import '../core/data/sqLite/database_service.dart';
import '../features/_main/cubit/main_cubit.dart';
import '../features/add_new_branch/cubit/add_new_branch_cubit.dart';
import '../features/add_new_branch/repos/offline/add_new_branch_offline_repos.dart';
import '../features/add_users/cubit/add_user_cubit.dart';
import '../features/add_users/repos/offline/add_user_offline_repos.dart';
import '../features/branches/cubit/branches_cubit.dart';
import '../features/branches/repos/offline/branches_offline_repos.dart';
import '../features/add_new_delivery/cubit/add_new_delivery_cubit.dart';
import '../features/add_new_delivery/repos/offline/add_new_delivery_offline_repos.dart';
import '../features/deliveries/cubit/delivery_men_cubit.dart';
import '../features/deliveries/repos/offline/deliveries_offline_repos.dart';
import '../features/drawer/cubit/drawer_cubit.dart';
import '../features/add_new_zone/cubit/add_new_zone_cubit.dart';
import '../features/add_new_zone/repos/offline/add_new_zone_offline_repos.dart';
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
    () => AddUserCubit(getIt<AddUserOfflineRepository>()),
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
}
