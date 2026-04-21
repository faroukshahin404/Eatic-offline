import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text.dart';
import '../../../core/widgets/pos_crud_ui.dart';
import '../../add_new_product/model/product_model.dart';

class ListOfProductsWidget extends StatefulWidget {
  const ListOfProductsWidget({
    super.key,
    required this.products,
    this.onEdit,
    this.onDelete,
  });

  final List<ProductModel> products;
  final void Function(ProductModel item)? onEdit;
  final void Function(ProductModel item)? onDelete;

  @override
  State<ListOfProductsWidget> createState() => _ListOfProductsWidgetState();
}

class _ListOfProductsWidgetState extends State<ListOfProductsWidget> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  static String _displayName(ProductModel p) {
    return p.name ?? p.nameEn ?? '-';
  }

  static String _priceText(ProductModel p) {
    if (p.defaultPrice != null && p.defaultPrice! > 0) {
      return NumberFormat('#,##0.00', 'en').format(p.defaultPrice);
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Center(
        child: Text(
          'products.no_products'.tr(),
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
                  Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'products'.tr(),
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
                          columnSpacing: 22,
                          horizontalMargin: 14,
                          dataRowMinHeight: 56,
                          dataRowMaxHeight: 72,
                          columns: [
                            DataColumn(label: Text('table.id'.tr())),
                            DataColumn(label: Text('table.name'.tr())),
                            DataColumn(label: Text('table.categories'.tr())),
                            DataColumn(label: Text('table.price'.tr())),
                            DataColumn(label: Text('table.variants'.tr())),
                            DataColumn(label: Text('table.actions'.tr())),
                          ],
                          rows: [
                            for (var i = 0; i < widget.products.length; i++)
                              DataRow(
                                color: WidgetStateProperty.all(
                                  i.isEven
                                      ? Colors.white
                                      : AppColors.fillColor,
                                ),
                                cells: [
                                  DataCell(
                                    CustomText(
                                      text:
                                          '${widget.products[i].id ?? '-'}',
                                      needSelectable: true,
                                    ),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 220,
                                      ),
                                      child: CustomText(
                                        text: _displayName(
                                          widget.products[i],
                                        ),
                                        needSelectable: true,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                      child: CustomText(
                                        text:
                                            (widget.products[i].categoryNames
                                                        ?.trim()
                                                        .isNotEmpty ==
                                                    true)
                                                ? widget
                                                    .products[i]
                                                    .categoryNames!
                                                : '-',
                                        needSelectable: true,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    CustomText(
                                      text: _priceText(widget.products[i]),
                                      needSelectable: true,
                                    ),
                                  ),
                                  DataCell(
                                    Icon(
                                      widget.products[i].hasVariants == true
                                          ? Icons.check_circle_outline
                                          : Icons.remove_circle_outline,
                                      size: 22,
                                      color:
                                          widget.products[i].hasVariants ==
                                                  true
                                              ? AppColors.primary
                                              : AppColors.greyA4ACAD,
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
                                            onTap: () => widget.onEdit!(
                                              widget.products[i],
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
                                            onTap: () => widget.onDelete!(
                                              widget.products[i],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
