import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/action_icon_widget.dart';
import '../../../core/widgets/custom_text.dart';
import '../model/delivery_model.dart';

class ListOfDeliveryMenWidget extends StatefulWidget {
  const ListOfDeliveryMenWidget({
    super.key,
    required this.deliveryMen,
    this.onEdit,
    this.onDelete,
  });

  final List<DeliveryModel> deliveryMen;
  final void Function(DeliveryModel item)? onEdit;
  final void Function(DeliveryModel item)? onDelete;

  @override
  State<ListOfDeliveryMenWidget> createState() => _ListOfDeliveryMenWidgetState();
}

class _ListOfDeliveryMenWidgetState extends State<ListOfDeliveryMenWidget> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deliveryMen.isEmpty) {
      return Center(
        child: Text(
          'table.no_delivery_men'.tr(),
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
                      DataColumn(label: Text('table.name'.tr())),
                      DataColumn(label: Text('table.phone'.tr())),
                      DataColumn(label: Text('table.branch_name'.tr())),
                      DataColumn(label: Text('table.actions'.tr())),
                    ],
                    rows: [
                      for (var i = 0; i < widget.deliveryMen.length; i++)
                        DataRow(
                          color: WidgetStateProperty.all(
                            i.isEven ? Colors.white : AppColors.fillColor,
                          ),
                          cells: [
                            DataCell(
                              CustomText(
                                text: '${widget.deliveryMen[i].id ?? '-'}',
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: widget.deliveryMen[i].name ?? '-',
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: widget.deliveryMen[i].displayPhone,
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: widget.deliveryMen[i].branchName ?? '-',
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
                                          widget.onEdit!(widget.deliveryMen[i]),
                                    ),
                                  if (widget.onDelete != null) ...[
                                    if (widget.onEdit != null)
                                      const SizedBox(width: 4),
                                    ActionIcon(
                                      icon: Icons.delete_outline,
                                      tooltip: 'actions.delete'.tr(),
                                      onTap: () =>
                                          widget.onDelete!(widget.deliveryMen[i]),
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
