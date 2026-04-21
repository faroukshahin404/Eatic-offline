import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/pos_crud_ui.dart';
import '../model/restaurant_table_model.dart';

class ListOfRestaurantTablesWidget extends StatelessWidget {
  const ListOfRestaurantTablesWidget({
    super.key,
    required this.restaurantTables,
    this.filterBranchId,
    this.onEdit,
    this.onDelete,
  });

  final List<RestaurantTableModel> restaurantTables;

  /// When non-null, only tables for this branch are shown.
  final int? filterBranchId;
  final void Function(RestaurantTableModel item)? onEdit;
  final void Function(RestaurantTableModel item)? onDelete;

  List<RestaurantTableModel> get _filtered {
    if (filterBranchId == null) return restaurantTables;
    return restaurantTables.where((t) => t.branchId == filterBranchId).toList();
  }

  /// Groups by dining area id; preserves stable order by name.
  List<MapEntry<String, List<RestaurantTableModel>>> _groupByDiningArea(
    List<RestaurantTableModel> list,
  ) {
    final map = <String, List<RestaurantTableModel>>{};
    for (final t in list) {
      final key = '${t.diningAreaId ?? 0}';
      map.putIfAbsent(key, () => []).add(t);
    }
    for (final entry in map.entries) {
      entry.value.sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
          (b.name ?? '').toLowerCase(),
        ),
      );
    }
    final keys =
        map.keys.toList()..sort((a, b) {
          final nameA = map[a]!.first.diningAreaName ?? '';
          final nameB = map[b]!.first.diningAreaName ?? '';
          return nameA.toLowerCase().compareTo(nameB.toLowerCase());
        });
    return [for (final k in keys) MapEntry(k, map[k]!)];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    if (restaurantTables.isEmpty) {
      return Center(
        child: Text(
          'table.no_restaurant_tables'.tr(),
          style: TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
        ),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'table.no_restaurant_tables'.tr(),
          style: TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
        ),
      );
    }

    final groups = _groupByDiningArea(filtered);

    return PosCrudSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.table_restaurant_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'restaurant_tables'.tr(),
                  style: AppFonts.styleSemiBold18.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final g in groups) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.dining_outlined,
                          size: 20,
                          color: AppColors.deepPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            g.value.first.diningAreaName ??
                                'table.dining_area'.tr(),
                            style: AppFonts.styleSemiBold16.copyWith(
                              color: AppColors.oppositeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final table in g.value)
                          _TableSquareCard(
                            table: table,
                            onEdit: onEdit,
                            onDelete: onDelete,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableSquareCard extends StatelessWidget {
  const _TableSquareCard({required this.table, this.onEdit, this.onDelete});

  final RestaurantTableModel table;
  final void Function(RestaurantTableModel item)? onEdit;
  final void Function(RestaurantTableModel item)? onDelete;

  bool get _available => table.isEmpty == 1;

  @override
  Widget build(BuildContext context) {
    final bg =
        _available ? AppColors.tableAvailableBg : AppColors.tableOccupiedBg;
    final border =
        _available
            ? AppColors.tableAvailableBorder
            : AppColors.tableOccupiedBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit != null ? () => onEdit!(table) : null,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        table.name ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.styleSemiBold14.copyWith(
                          color: AppColors.oppositeColor,
                        ),
                      ),
                    ),
                    if (onEdit != null || onDelete != null)
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.black12,
                          highlightColor: Colors.black12,
                        ),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: AppColors.oppositeColor.withOpacity(0.7),
                          ),
                          onSelected: (value) {
                            if (value == 'edit' && onEdit != null) {
                              onEdit!(table);
                            }
                            if (value == 'delete' && onDelete != null) {
                              onDelete!(table);
                            }
                          },
                          itemBuilder:
                              (context) => [
                                if (onEdit != null)
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('actions.edit'.tr()),
                                      ],
                                    ),
                                  ),
                                if (onDelete != null)
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: Colors.red.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('actions.delete'.tr()),
                                      ],
                                    ),
                                  ),
                              ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  '#${table.id ?? '-'}',
                  style: AppFonts.styleRegular12.copyWith(
                    color: AppColors.greyA4ACAD,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _available
                      ? 'orders_status.table_free'.tr()
                      : 'orders_status.table_active'.tr(),
                  style: AppFonts.styleMedium14.copyWith(
                    fontSize: 12,
                    color: _available
                        ? AppColors.primary
                        : AppColors.validationError,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
