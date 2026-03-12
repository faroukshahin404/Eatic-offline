import 'dart:ui' show BlendMode;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../cubit/select_table_cubit.dart';
import '../../restaurant_tables/model/restaurant_table_model.dart';

/// Table card for grid: available (grey), selected (green). Tappable to select.
class TableCardItem extends StatelessWidget {
  const TableCardItem({super.key, required this.table});

  final RestaurantTableModel table;

  static const Color _availableBg = Color(0xFFE0E0E0);
  static const Color _availableBorder = Color(0xFFE0E0E0);
  static const Color _selectedBg = Color(0xFFE8F5E9);
  static const Color _selectedBorder = Color(0xFF81C784);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SelectTableCubit>();
    final isSelected = cubit.selectedTable?.id == table.id;

    final bg = isSelected ? _selectedBg : _availableBg;
    final border = isSelected ? _selectedBorder : _availableBorder;

    return InkWell(
      onTap: () => cubit.setSelectedTable(isSelected ? null : table),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          VectorGraphic(
            width: 100,
            height: 100,
            loader: AssetBytesLoader(AppAssets.tableIcon),
            colorFilter: ColorFilter.mode(border, BlendMode.srcIn),
          ),
          const SizedBox(height: 8),
          Text(
            table.name ?? 'T${table.id ?? ''}',
            style: AppFonts.styleBold18.copyWith(
              color: AppColors.oppositeColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
