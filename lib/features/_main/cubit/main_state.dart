part of 'main_cubit.dart';

sealed class MainState {
  const MainState({required this.customerInfoPanelVisible});

  final bool customerInfoPanelVisible;
}

final class MainInitial extends MainState {
  const MainInitial({required super.customerInfoPanelVisible});
}

final class MainScreenChanged extends MainState {
  const MainScreenChanged({required super.customerInfoPanelVisible});
}

final class MainCustomerInfoPanelChanged extends MainState {
  const MainCustomerInfoPanelChanged({required super.customerInfoPanelVisible});
}
