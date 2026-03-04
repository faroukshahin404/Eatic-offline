import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text.dart';
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
                                    widget.currencies[i].updatedAt),
                                needSelectable: true,
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onEdit != null)
                                    _ActionIcon(
                                      icon: Icons.edit_outlined,
                                      tooltip: 'actions.edit'.tr(),
                                      onTap: () =>
                                          widget.onEdit!(widget.currencies[i]),
                                    ),
                                  if (widget.onDelete != null) ...[
                                    if (widget.onEdit != null)
                                      const SizedBox(width: 4),
                                    _ActionIcon(
                                      icon: Icons.delete_outline,
                                      tooltip: 'actions.delete'.tr(),
                                      onTap: () => widget
                                          .onDelete!(widget.currencies[i]),
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

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 22, color: AppColors.primary),
        style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
      ),
    );
  }
}
