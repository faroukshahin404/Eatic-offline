import 'dart:ui' show BlendMode;

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text.dart';
import '../cubit/select_table_cubit.dart';
import '../../restaurant_tables/model/restaurant_table_model.dart';

class TableCardItem extends StatelessWidget {
  const TableCardItem({super.key, required this.table, required this.cubit});

  final RestaurantTableModel table;
  final SelectTableCubit cubit;

  static Color _cardBackgroundColor({
    required bool isOccupied,
    required bool isSelected,
  }) {
    if (isOccupied) return AppColors.tableNotEmpty;
    if (isSelected) return AppColors.tableSelectedBorder;
    return AppColors.tableAvailableBg;
  }

  @override
  Widget build(BuildContext context) {
    final isSelected =
        !(table.isEmpty == 0) && cubit.selectedTable?.id == table.id;

    return InkWell(
      mouseCursor: table.isEmpty == 0 ? null : SystemMouseCursors.click,
      overlayColor: table.isEmpty != 0
          ? null
          : WidgetStateProperty.all(Colors.transparent),
      onTap: table.isEmpty == 0
          ? null
          : () => cubit.setSelectedTable(isSelected ? null : table),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // VectorGraphic(
          //   width: 100,
          //   height: 100,
          //   loader: AssetBytesLoader(AppAssets.tableIcon),
          //   colorFilter: ColorFilter.mode(
          //     _cardBackgroundColor(
          //       isOccupied: table.isEmpty == 0,
          //       isSelected: isSelected,
          //     ),
          //     BlendMode.srcIn,
          //   ),
          // ),
          const SizedBox(height: 8),
          CustomText(
            text: table.name ?? 'T${table.id ?? ''}',
            style: AppFonts.styleBold18.copyWith(
              color: AppColors.oppositeColor,
            ),
          ),
        ],
      ),
    );
  }
}
