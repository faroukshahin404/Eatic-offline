import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/action_icon_widget.dart';
import '../../../core/widgets/custom_text.dart';
import '../model/zone_model.dart';

class ListOfZonesWidget extends StatefulWidget {
  const ListOfZonesWidget({
    super.key,
    required this.zones,
    this.onEdit,
    this.onDelete,
  });

  final List<ZoneModel> zones;
  final void Function(ZoneModel item)? onEdit;
  final void Function(ZoneModel item)? onDelete;

  @override
  State<ListOfZonesWidget> createState() => _ListOfZonesWidgetState();
}

class _ListOfZonesWidgetState extends State<ListOfZonesWidget> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  static String _formatLastUpdate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final dt = DateTime.parse(value);
      return DateFormat('d MMM yyyy, HH:mm', 'en').format(dt);
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.zones.isEmpty) {
      return Center(
        child: Text(
          'table.no_zones'.tr(),
          style: TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.secondary,
                    ),
                    columns: [
                      DataColumn(label: Text('table.id'.tr())),
                      DataColumn(label: Text('table.zone'.tr())),
                      DataColumn(label: Text('table.branch_name'.tr())),
                      DataColumn(label: Text('table.last_update'.tr())),
                      DataColumn(label: Text('table.actions'.tr())),
                    ],
                    rows: [
                      for (var i = 0; i < widget.zones.length; i++)
                        DataRow(
                          color: WidgetStateProperty.all(
                            i.isEven ? Colors.white : AppColors.fillColor,
                          ),
                          cells: [
                            DataCell(
                              CustomText(
                                text: '${widget.zones[i].id ?? '-'}',
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: widget.zones[i].name ?? '-',
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: widget.zones[i].branchName ?? '-',
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: _formatLastUpdate(widget.zones[i].updatedAt),
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onEdit != null)
                                    ActionIcon(
                                      icon: Icons.edit_outlined,
                                      tooltip: 'actions.edit'.tr(),
                                      onTap: () =>
                                          widget.onEdit!(widget.zones[i]),
                                    ),
                                  if (widget.onDelete != null) ...[
                                    if (widget.onEdit != null)
                                      const SizedBox(width: 4),
                                    ActionIcon(
                                      icon: Icons.delete_outline,
                                      tooltip: 'actions.delete'.tr(),
                                      onTap: () =>
                                          widget.onDelete!(widget.zones[i]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
