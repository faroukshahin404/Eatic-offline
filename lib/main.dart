import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/utils/app_utils.dart';
import 'features/_main/cubit/main_cubit.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/custody/cubit/custody_cubit.dart';
import 'features/drawer/cubit/drawer_cubit.dart';
import 'routes/app_routes.dart';
import 'services_locator/service_locator.dart';

// runZonedGuarded(() {
//   mains();
// }, (error, stackTrace) {
//   print(error);
//   print(stackTrace);
// });

// 12321312
// 123123123
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppUtils.appSetup();

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainCubit>(create: (context) => getIt<MainCubit>()),
        BlocProvider<DrawerCubit>(create: (context) => getIt<DrawerCubit>()),
        BlocProvider<CartCubit>(create: (_) => getIt<CartCubit>()),
        BlocProvider<CustodyCubit>(create: (_) => getIt<CustodyCubit>()),
      ],
      child: MaterialApp.router(
        title: "Eatic",
        theme: AppColors.androidTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppPages.router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: const Locale('ar'),
      ),
    );
  }
}
