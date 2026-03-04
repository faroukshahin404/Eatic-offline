import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../routes/app_paths.dart';
import '../../home/home_screen.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitial());

  String currentScreen = AppPaths.home;

  void setCurrentScreen(String screen) {
    emit(MainInitial());

    currentScreen = screen;

    emit(MainScreenChanged());
  }

  Widget getCurrentScreen() {
    switch (currentScreen) {
      case AppPaths.home:
        return const HomeScreen();
      default:
        return const HomeScreen();
    }
  }
}
