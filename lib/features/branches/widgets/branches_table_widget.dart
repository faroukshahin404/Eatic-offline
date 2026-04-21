import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/pos_crud_ui.dart';
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
      builder:
          (ctx) => AlertDialog(
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
        return PosCrudSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'branches'.tr(),
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
                                                  widget.branches[i],
                                                ),
                                          ),
                                        _TableActionButton(
                                          icon: Icons.delete_outline,
                                          label: 'actions.delete'.tr(),
                                          iconColor: Colors.red.shade700,
                                          backgroundColor: const Color(
                                            0xFFFFF0F0,
                                          ),
                                          borderColor: const Color(0xFFFFD9D9),
                                          onTap:
                                              () => onDelete(
                                                context,
                                                widget.branches[i],
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
