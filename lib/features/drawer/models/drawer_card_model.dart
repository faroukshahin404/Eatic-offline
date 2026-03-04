class DrawerCardModel {
  final String title;
  final String icon;
  final String? path, currentScreen;

  DrawerCardModel({
    required this.title,
    required this.icon,
    this.path,
    this.currentScreen,
  });
}
