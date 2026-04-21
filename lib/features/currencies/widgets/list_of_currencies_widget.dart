import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/pos_crud_ui.dart';
import '../model/currency_model.dart';

class ListOfCurrenciesWidget extends StatefulWidget {
  const ListOfCurrenciesWidget({
    super.key,
    required this.currencies,
    this.onEdit,
    this.onDelete,
  });

  final List<CurrencyModel> currencies;
  final void Function(CurrencyModel item)? onEdit;
  final void Function(CurrencyModel item)? onDelete;

  @override
  State<ListOfCurrenciesWidget> createState() => _ListOfCurrenciesWidgetState();
}

class _ListOfCurrenciesWidgetState extends State<ListOfCurrenciesWidget> {
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
    if (widget.currencies.isEmpty) {
      return Center(
        child: Text(
          'table.no_currencies'.tr(),
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
                  Icon(
                    Icons.currency_exchange_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'currencies'.tr(),
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
                            DataColumn(label: Text('table.symbol'.tr())),
                            DataColumn(label: Text('table.last_update'.tr())),
                            DataColumn(label: Text('table.actions'.tr())),
                          ],
                          rows: [
                            for (var i = 0; i < widget.currencies.length; i++)
                              DataRow(
                                color: WidgetStateProperty.all(
                                  i.isEven ? Colors.white : AppColors.fillColor,
                                ),
                                cells: [
                                  DataCell(
                                    CustomText(
                                      text: '${widget.currencies[i].id ?? '-'}',
                                      needSelectable: true,
                                    ),
                                  ),
                                  DataCell(
                                    CustomText(
                                      text: widget.currencies[i].name ?? '-',
                                      needSelectable: true,
                                    ),
                                  ),
                                  DataCell(
                                    CustomText(
                                      text: widget.currencies[i].code ?? '-',
                                      needSelectable: true,
                                    ),
                                  ),
                                  DataCell(
                                    CustomText(
                                      text: widget.currencies[i].symbol ?? '-',
                                      needSelectable: true,
                                    ),
                                  ),
                                  DataCell(
                                    CustomText(
                                      text: _formatLastUpdate(
                                        widget.currencies[i].updatedAt,
                                      ),
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
                                                  widget.currencies[i],
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
                                                  widget.currencies[i],
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
