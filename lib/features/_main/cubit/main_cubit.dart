import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../routes/app_paths.dart';
import '../../create_order/create_order_screen.dart';
import '../../home/home_screen.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitial());

  String currentScreen = AppPaths.home;
  dynamic data;

  void setCurrentScreen(String screen, {dynamic data}) {
    emit(MainInitial());

    currentScreen = screen;
    this.data = data;
    emit(MainScreenChanged());
  }

  Widget getCurrentScreen() {
    switch (currentScreen) {
      case AppPaths.home:
        return const HomeScreen();
      case AppPaths.createOrder:
        return CreateOrderScreen(productId: data as int);

      default:
        return const HomeScreen();
    }
  }
}
