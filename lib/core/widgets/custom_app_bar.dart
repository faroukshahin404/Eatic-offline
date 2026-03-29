import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_size.dart';
import 'custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.titleWidget,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation,
    this.forceShow = false,
  });

  final Widget? titleWidget;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle, forceShow;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppSize.tablet;

    // if (!isMobile && !forceShow) {
    //   return const SizedBox.shrink();
    // }

    return AppBar(
      title:
          titleWidget ??
          CustomText(
            text: title ?? "",
            style: AppFonts.styleBold24.copyWith(
              fontFamily: AppFonts.getCurrentFontFamilyBasedOnText((title ?? '').tr()),
            ),
          ),
      automaticallyImplyLeading: isMobile || context.canPop(),
      iconTheme: IconThemeData(color: AppColors.primary),
      leading: isMobile || context.canPop() ? leading : null,
      actions: actions,
      centerTitle: centerTitle ?? false,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: Border(
        top: BorderSide(color: AppColors.greyE6E9EA),
        bottom: BorderSide(color: AppColors.greyE6E9EA),
      ),
    );
  }
}
