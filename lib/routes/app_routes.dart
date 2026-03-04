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
import '../features/add_new_zone/add_new_zone_screen.dart';
import '../features/zones/cubit/zones_cubit.dart';
import '../features/zones/zones_screen.dart';
import '../features/login/login_screen.dart';
import '../features/reset_password/cubit/reset_password_cubit.dart';
import '../features/reset_password/reset_password_screen.dart';
import '../features/setting/setting_screen.dart';
import '../features/splash_screen.dart';
import '../features/users/cubit/users_cubit.dart';
import '../features/users/users_screen.dart';
import '../services_locator/service_locator.dart';
import 'app_paths.dart';

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
      GoRoute(
        path: AppPaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppPaths.main,
        builder: (context, state) => const MainScreen(),
      ),

      GoRoute(
        path: AppPaths.login,
        builder: (context, state) => BlocProvider<LoginCubit>(
          create: (context) => getIt<LoginCubit>(),
          child: const LoginScreen(),
        ),
      ),

      GoRoute(
        path: AppPaths.settings,
        builder: (context, state) => SettingScreen(),
      ),

      GoRoute(
        path: AppPaths.users,
        builder: (context, state) => BlocProvider<UsersCubit>(
          create: (context) => getIt<UsersCubit>()..getUsers(),
          child: UsersScreen(),
        ),
      ),

      GoRoute(
        path: AppPaths.addUser,
        builder: (context, state) => BlocProvider<AddUserCubit>(
          create: (context) =>
              getIt<AddUserCubit>()..getRoles(id: state.extra as int?),
          child: AddUserScreen(userId: state.extra as int?),
        ),
      ),

      GoRoute(
        path: AppPaths.addBranch,
        builder: (context, state) => BlocProvider<AddNewBranchCubit>(
          create: (context) => getIt<AddNewBranchCubit>(),
          child: const AddNewBranchScreen(),
        ),
      ),

      GoRoute(
        path: AppPaths.branches,
        builder: (context, state) => BlocProvider<BranchesCubit>(
          create: (context) => getIt<BranchesCubit>()..getBranches(),
          child: BranchesScreen(),
        ),
      ),

      GoRoute(
        path: AppPaths.deliveryMen,
        builder: (context, state) => BlocProvider<DeliveryMenCubit>(
          create: (context) => getIt<DeliveryMenCubit>()..getAll(),
          child: const DeliveryMenScreen(),
        ),
      ),

      GoRoute(
        path: AppPaths.addDelivery,
        builder: (context, state) => BlocProvider<AddNewDeliveryCubit>(
          create: (context) {
            final cubit = getIt<AddNewDeliveryCubit>();
            if (state.extra != null) cubit.setDeliveryIdForEdit(state.extra as int);
            cubit.loadBranches();
            return cubit;
          },
          child: AddNewDeliveryScreen(deliveryId: state.extra as int?),
        ),
      ),

      GoRoute(
        path: AppPaths.zones,
        builder: (context, state) => BlocProvider<ZonesCubit>(
          create: (context) => getIt<ZonesCubit>()..getAllZones(),
          child: const ZonesScreen(),
        ),
      ),

      GoRoute(
        path: AppPaths.addZone,
        builder: (context, state) => AddNewZoneScreen(
          zoneId: state.extra as int?,
        ),
      ),

      GoRoute(
        path: AppPaths.resetPassword,
        builder: (context, state) => BlocProvider<ResetPasswordCubit>(
          create: (context) => getIt<ResetPasswordCubit>(),
          child: const ResetPasswordScreen(),
        ),
      ),
    ],
  );
}
