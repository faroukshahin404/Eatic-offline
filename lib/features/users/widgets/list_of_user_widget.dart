import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/pos_crud_ui.dart';
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
        return PosCrudSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.people_alt_outlined, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'users'.tr(),
                    style: AppFonts.styleSemiBold18.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Scrollbar(
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
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.secondary,
                          ),
                          headingTextStyle: AppFonts.styleSemiBold16.copyWith(
                            color: AppColors.primary,
                          ),
                          dataTextStyle: AppFonts.styleRegular15.copyWith(
                            color: AppColors.oppositeColor,
                          ),
                          columnSpacing: 24,
                          horizontalMargin: 14,
                          dataRowMinHeight: 60,
                          dataRowMaxHeight: 60,
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
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        if (widget.onEdit != null)
                                          _TableActionButton(
                                            icon: Icons.edit_outlined,
                                            label: 'actions.edit'.tr(),
                                            iconColor: AppColors.primary,
                                            backgroundColor:
                                                AppColors.secondary,
                                            borderColor: AppColors.secondary,
                                            onTap:
                                                () => widget.onEdit!(
                                                  widget.users[i],
                                                ),
                                          ),
                                        if (widget.onDelete != null)
                                          _TableActionButton(
                                            icon: Icons.delete_outline,
                                            label: 'actions.delete'.tr(),
                                            iconColor: Colors.red.shade700,
                                            backgroundColor: const Color(
                                              0xFFFFF0F0,
                                            ),
                                            borderColor: const Color(
                                              0xFFFFD9D9,
                                            ),
                                            onTap:
                                                () => widget.onDelete!(
                                                  widget.users[i],
                                                ),
                                          ),
                                        if (widget.onView != null)
                                          _TableActionButton(
                                            icon: Icons.visibility_outlined,
                                            label: 'actions.view'.tr(),
                                            iconColor: const Color(0xFFB26A00),
                                            backgroundColor: const Color(
                                              0xFFFFF8EA,
                                            ),
                                            borderColor: const Color(
                                              0xFFFFE6B8,
                                            ),
                                            onTap:
                                                () => widget.onView!(
                                                  widget.users[i],
                                                ),
                                          ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TableActionButton extends StatelessWidget {
  const _TableActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          style: AppFonts.styleMedium14.copyWith(color: iconColor),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: iconColor,
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
