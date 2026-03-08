import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../cubit/add_new_product_cubit.dart';
import '../model/add_product_input.dart';

class AddNewProductVariantsSection extends StatelessWidget {
  const AddNewProductVariantsSection({super.key, required this.cubit});
  final AddNewProductCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'add_product_form.variants'.tr(),
          style: AppFonts.styleBold18.copyWith(color: AppColors.oppositeColor),
        ),
        const SizedBox(height: 12),
        ...List.generate(cubit.variableRows.length, (rowIndex) {
          final row = cubit.variableRows[rowIndex];
          return _VariableRowCard(
            key: ValueKey(row.id),
            rowIndex: rowIndex,
            row: row,
            cubit: cubit,
          );
        }),
        const SizedBox(height: 8),
        CustomButtonWidget(
          text: 'add_product_form.add_variable'.tr(),
          onPressed: () => cubit.addVariableRow(),
        ),
      ],
    );
  }
}

class _VariableRowCard extends StatefulWidget {
  const _VariableRowCard({
    super.key,
    required this.rowIndex,
    required this.row,
    required this.cubit,
  });
  final int rowIndex;
  final ProductVariableRow row;
  final AddNewProductCubit cubit;

  @override
  State<_VariableRowCard> createState() => _VariableRowCardState();
}

class _VariableRowCardState extends State<_VariableRowCard> {
  late TextEditingController _nameController;
  final List<TextEditingController> _valueControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.row.name);
    for (final v in widget.row.values) {
      _valueControllers.add(TextEditingController(text: v));
    }
  }

  @override
  void didUpdateWidget(covariant _VariableRowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.row.name != _nameController.text) {
      _nameController.text = widget.row.name;
    }
    while (_valueControllers.length < widget.row.values.length) {
      final i = _valueControllers.length;
      _valueControllers.add(
        TextEditingController(text: widget.row.values[i]),
      );
    }
    while (_valueControllers.length > widget.row.values.length) {
      _valueControllers.removeLast().dispose();
    }
    for (var i = 0; i < _valueControllers.length && i < widget.row.values.length; i++) {
      if (widget.row.values[i] != _valueControllers[i].text) {
        _valueControllers[i].text = widget.row.values[i];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _valueControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit;
    final rowIndex = widget.rowIndex;
    final row = widget.row;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyE6E9EA),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'add_product_form.variable_name'.tr(),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (v) => cubit.setVariableName(rowIndex, v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(row.values.length, (valueIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _valueControllers[valueIndex],
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                      ),
                                      onChanged: (v) => cubit.setVariableValue(
                                          rowIndex, valueIndex, v),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        color: Colors.red, size: 22),
                                    onPressed: () => cubit.removeVariableValue(
                                        rowIndex, valueIndex),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        TextButton.icon(
                          onPressed: () => cubit.addVariableValue(rowIndex),
                          icon: const Icon(Icons.add, size: 20),
                          label: Text('add_product_form.add_value'.tr()),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => cubit.removeVariableRow(rowIndex),
                  tooltip: 'add_product_form.delete'.tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
