import 'package:Eatic/core/utils/app_utils.dart';
import 'package:Eatic/features/_main/cubit/main_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_size.dart';
import '../../../routes/app_paths.dart';
import '../models/drawer_card_model.dart';

part 'drawer_state.dart';

class DrawerCubit extends Cubit<DrawerState> {
  DrawerCubit() : super(DrawerInitial());

  int selectedDrawerCardIndex = 0;

  List<DrawerCardModel> drawerCards = [
    DrawerCardModel(
      title: 'home',
      icon: AppAssets.homeIcon,
      currentScreen: AppPaths.home,
    ),
    DrawerCardModel(
      title: 'custody',
      icon: AppAssets.homeIcon,
      currentScreen: AppPaths.custody,
    ),
    DrawerCardModel(
      title: 'settings',
      icon: AppAssets.settingsIcon,
      path: AppPaths.settings,
    ),
  ];
  void changeSelectedDrawerCard(int index) {
    final currentCard = drawerCards[index];

    if (currentCard.path != null) return;
    emit(DrawerInitial());

    selectedDrawerCardIndex = index;
    emit(DrawerSelectedCardChanged());
  }

  void navigateTo({required int index}) {
    if (selectedDrawerCardIndex == index) {
      if (AppSize.isMobile()) {
        AppUtils.navigatorKey.currentContext!.pop();
      }
      return;
    }

    changeSelectedDrawerCard(index);

    final currentCard = drawerCards[index];

    if (currentCard.path != null) {
      AppUtils.navigatorKey.currentContext!.push(currentCard.path!);
    } else {
      AppUtils.navigatorKey.currentContext!.read<MainCubit>().setCurrentScreen(
        currentCard.currentScreen!,
      );
    }
  }
}