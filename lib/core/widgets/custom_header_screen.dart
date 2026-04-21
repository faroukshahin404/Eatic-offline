import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../../features/_main/cubit/main_cubit.dart';

/// Back button with title; tap navigates to [path] (or home when [path] is null).
/// Use as a reusable header for screens that need a back + title bar.
class CustomHeaderScreen extends StatelessWidget {
  const CustomHeaderScreen({
    super.key,
    required this.title,
    this.path,
  });

  final String title;

  /// When non-null, back tap navigates to this screen (e.g. [AppPaths.home]).
  /// When null, back tap calls [MainCubit.setCurrentScreen] (default home).
  final String? path;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.secondary.withValues(alpha: 0.35);
            }
            return Colors.transparent;
          }),
          onTap: () {
            context.read<MainCubit>().setCurrentScreen(
                  screen: path,
                );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.oppositeColor,
                  size: 28,
                ),
                Text(
                  title,
                  style: AppFonts.styleBold40.copyWith(
                    color: AppColors.oppositeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
