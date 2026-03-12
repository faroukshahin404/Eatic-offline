import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../cubit/select_table_cubit.dart';
import 'table_card_item.dart';

/// Grid of table cards (4 columns, ~20px spacing). Empty state when no tables.
class TableGridWidget extends StatelessWidget {
  const TableGridWidget({super.key});

  static const int _crossAxisCount = 4;
  static const double _mainSpacing = 20;
  static const double _crossSpacing = 20;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectTableCubit, SelectTableState>(
      builder: (context, state) {
        final cubit = context.read<SelectTableCubit>();
        final tables = cubit.tables;

        if (tables.isEmpty) {
          return Center(
            child: Text(
              'select_table.empty'.tr(),
              style: TextStyle(
                color: AppColors.greyA4ACAD,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            mainAxisSpacing: _mainSpacing,
            crossAxisSpacing: _crossSpacing,
            childAspectRatio: 0.95,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            return TableCardItem(table: tables[index]);
          },
        );
      },
    );
  }
}
