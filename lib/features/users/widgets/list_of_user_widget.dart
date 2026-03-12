import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/action_icon_widget.dart';
import '../../../core/widgets/custom_text.dart';
import '../model/user_model.dart';

class ListOfUserWidget extends StatefulWidget {
  const ListOfUserWidget({
    super.key,
    required this.users,
    this.onEdit,
    this.onDelete,
    this.onView,
  });

  final List<UserModel> users;
  final void Function(UserModel user)? onEdit;
  final void Function(UserModel user)? onDelete;
  final void Function(UserModel user)? onView;

  @override
  State<ListOfUserWidget> createState() => _ListOfUserWidgetState();
}

class _ListOfUserWidgetState extends State<ListOfUserWidget> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  static String _roleName(int roleId) {
    const names = ['admin', 'supervisor', 'cashier', 'waiter'];
    final index = (roleId - 1).clamp(0, names.length - 1);
    return names[index];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return Center(
        child: Text(
          'table.no_users'.tr(),
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
                      DataColumn(label: Text('table.code'.tr())),
                      DataColumn(label: Text('table.role'.tr())),
                      DataColumn(label: Text('table.actions'.tr())),
                    ],
                    rows: [
                      for (var i = 0; i < widget.users.length; i++)
                        DataRow(
                          color: WidgetStateProperty.all(
                            i.isEven ? Colors.white : AppColors.fillColor,
                          ),
                          cells: [
                            DataCell(
                              CustomText(
                                text: '${widget.users[i].id ?? '-'}',
                                needSelectable: true,
                                
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: widget.users[i].name ?? '-',
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: widget.users[i].code,
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: _roleName(widget.users[i].roleId),
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
                                          widget.onEdit!(widget.users[i]),
                                    ),
                                  if (widget.onDelete != null) ...[
                                    const SizedBox(width: 4),
                                    ActionIcon(
                                      icon: Icons.delete_outline,
                                      tooltip: 'actions.delete'.tr(),
                                      onTap: () =>
                                          widget.onDelete!(widget.users[i]),
                                    ),
                                  ],
                                  if (widget.onView != null) ...[
                                    const SizedBox(width: 4),
                                    ActionIcon(
                                      icon: Icons.visibility_outlined,
                                      tooltip: 'actions.view'.tr(),
                                      onTap: () =>
                                          widget.onView!(widget.users[i]),
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
