import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/action_icon_widget.dart';
import '../../../core/widgets/custom_text.dart';
import '../cubit/branches_cubit.dart';
import '../model/branch_model.dart';

/// Table widget displaying branches with columns: id, branch name, created at, created by, actions.
class BranchesTableWidget extends StatefulWidget {
  const BranchesTableWidget({super.key, required this.branches, this.onEdit});

  final List<BranchModel> branches;
  final void Function(BranchModel branch)? onEdit;

  @override
  State<BranchesTableWidget> createState() => _BranchesTableWidgetState();
}

class _BranchesTableWidgetState extends State<BranchesTableWidget> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  static String _formatCreatedAt(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final dt = DateTime.parse(value);
      return DateFormat('d MMMM yyyy - h:mm a', "en").format(dt);
    } catch (_) {
      return value;
    }
  }

  Future<void> onDelete(BuildContext context, BranchModel branch) async {
    if (branch.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('actions.delete'.tr()),
        content: Text(
          'branches.delete_confirm'.tr(namedArgs: {'name': branch.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('dialog.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('actions.delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<BranchesCubit>().removeBranch(branch.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.branches.isEmpty) {
      return Center(
        child: Text(
          'table.no_branches'.tr(),
          style: const TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
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
                      DataColumn(label: Text('table.branch_name'.tr())),
                      DataColumn(label: Text('table.created_at'.tr())),
                      DataColumn(label: Text('table.created_by'.tr())),
                      DataColumn(label: Text('table.actions'.tr())),
                    ],
                    rows: [
                      for (var i = 0; i < widget.branches.length; i++)
                        DataRow(
                          color: WidgetStateProperty.all(
                            i.isEven ? Colors.white : AppColors.fillColor,
                          ),
                          cells: [
                            DataCell(
                              CustomText(
                                needSelectable: true,
                                text: '${widget.branches[i].id ?? '-'}',
                                style: AppFonts.styleBold16.copyWith(
                                  fontFamily: AppFonts.enFamily,
                                ),
                              ),
                            ),
                            DataCell(
                              CustomText(
                                text: widget.branches[i].name,
                                needSelectable: true,
                                style: AppFonts.styleBold16.copyWith(
                                  fontFamily:
                                      AppFonts.getCurrentFontFamilyBasedOnText(
                                        widget.branches[i].name,
                                      ),
                                ),
                              ),
                            ),
                            DataCell(
                              CustomText(
                                needSelectable: true,
                                text:
                                    '\u200E${_formatCreatedAt(widget.branches[i].createdAt)}',
                                style: AppFonts.styleBold16.copyWith(
                                  fontFamily: AppFonts.enFamily,
                                ),
                              ),
                            ),
                            DataCell(
                              CustomText(
                                needSelectable: true,
                                text:
                                    widget.branches[i].createdBy?.name ??
                                    widget.branches[i].createdBy?.code ??
                                    '-',
                                style: AppFonts.styleBold16.copyWith(
                                  fontFamily: AppFonts.enFamily,
                                ),
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
                                          widget.onEdit!(widget.branches[i]),
                                    ),

                                  const SizedBox(width: 4),
                                  ActionIcon(
                                    icon: Icons.delete_outline,
                                    tooltip: 'actions.delete'.tr(),
                                    onTap: () =>
                                        onDelete(context, widget.branches[i]),
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
        );
      },
    );
  }
}
