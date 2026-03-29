import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../restaurant_tables/model/restaurant_table_model.dart';

class TablesGridViewWidget extends StatelessWidget {
  const TablesGridViewWidget({
    super.key,
    required this.tables,
    required this.onFreeTableTap,
    required this.onOccupiedTableTap,
  });

  final List<RestaurantTableModel> tables;

  /// Called when a free (isEmpty == 1) table is tapped.
  final void Function(RestaurantTableModel table) onFreeTableTap;

  /// Called when an occupied (isEmpty == 0) table is tapped.
  final void Function(RestaurantTableModel table) onOccupiedTableTap;

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return Center(
        child: Text(
          'orders_status.no_tables'.tr(),
          style: AppFonts.styleMedium16.copyWith(
            color: AppColors.inactiveTextColor,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        final isFree = table.isEmpty == 1;
        return _TableCard(
          table: table,
          isFree: isFree,
          onTap: () => isFree
              ? onFreeTableTap(table)
              : onOccupiedTableTap(table),
        );
      },
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.table,
    required this.isFree,
    required this.onTap,
  });

  final RestaurantTableModel table;
  final bool isFree;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tableName = table.name ?? '-';
    final statusText = isFree
        ? 'orders_status.table_free'.tr()
        : 'orders_status.table_active'.tr();
    final buttonText = isFree
        ? 'orders_status.create_hall_order'.tr()
        : 'orders_status.edit_active_order'.tr();

    final bgColor = isFree ? AppColors.tableFreeBg : AppColors.tableActiveBg;
    final borderColor =
        isFree ? AppColors.tableFreeBorder : AppColors.tableActiveBorder;
    final accentColor = isFree ? AppColors.primary : AppColors.validationError;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tableName,
              style: AppFonts.styleBold18.copyWith(
                color: AppColors.oppositeColor,
                fontFamily: AppFonts.getCurrentFontFamilyBasedOnText(tableName),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: AppFonts.styleMedium14.copyWith(
                color: accentColor,
                fontFamily:
                    AppFonts.getCurrentFontFamilyBasedOnText(statusText),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: AppFonts.styleMedium14.copyWith(
                    color: Colors.white,
                    fontFamily:
                        AppFonts.getCurrentFontFamilyBasedOnText(buttonText),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
