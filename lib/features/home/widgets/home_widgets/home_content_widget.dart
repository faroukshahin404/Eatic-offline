import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/custom_failed_widget.dart';
import '../../../../core/widgets/custom_grid_view.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../_main/cubit/main_cubit.dart';
import '../../../add_new_product/model/product_model.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/cubit/cart_state.dart';
import '../../../price_lists/model/price_list_model.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';
import 'categories_row_widget.dart';
import 'customer_info_menu_panel.dart';
import 'home_product_card.dart';

class HomeContentWidget extends StatelessWidget {
  const HomeContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return CustomFailedWidget(
            message: state.message,
            onRetry: () => context.read<HomeCubit>().loadData(),
          );
        }
        if (state is HomeLoaded) {
          return BlocBuilder<MainCubit, MainState>(
            buildWhen:
                (p, c) =>
                    p.customerInfoPanelVisible != c.customerInfoPanelVisible,
            builder: (context, mainState) {
              if (mainState.customerInfoPanelVisible) {
                return BlocBuilder<CartCubit, CartState>(
                  buildWhen:
                      (p, c) =>
                          p.selectedOrderTypeIndex != c.selectedOrderTypeIndex,
                  builder: (context, cartState) {
                    final isDeliveryOrTakeaway =
                        cartState.selectedOrderTypeIndex == 1 ||
                        cartState.selectedOrderTypeIndex == 2;
                    if (!isDeliveryOrTakeaway) {
                      return const SizedBox.shrink();
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: CustomerInfoMenuPanel(),
                    );
                  },
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoriesRow(
                    categories: state.categories,
                    selectedCategoryId: state.selectedCategoryId,
                    onSelectCategory:
                        (id) => context.read<HomeCubit>().selectCategory(id),
                  ),
                  BlocBuilder<CartCubit, CartState>(
                    buildWhen:
                        (p, c) =>
                            p.orderPriceLists != c.orderPriceLists ||
                            p.selectedOrderPriceListId !=
                                c.selectedOrderPriceListId,
                    builder: (context, cartState) {
                      final items = cartState.orderPriceLists;
                      if (items.isEmpty) return const SizedBox.shrink();
                      PriceListModel? selected;
                      for (final p in items) {
                        if (p.id == cartState.selectedOrderPriceListId) {
                          selected = p;
                          break;
                        }
                      }
                      selected ??= items.first;
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 290,
                            child: CustomDropDown<PriceListModel>(
                              items: items,
                              value: selected,
                              label: 'create_order.select_price_plan'.tr(),
                              itemLabelBuilder:
                                  (pl) =>
                                      pl.name?.isNotEmpty == true
                                          ? pl.name!
                                          : 'create_order.price_list_id'.tr(
                                            namedArgs: {'id': '${pl.id}'},
                                          ),
                              onChanged:
                                  (pl) => context
                                      .read<CartCubit>()
                                      .setSelectedOrderPriceListId(pl?.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(
                    color: AppColors.greyA4ACAD,
                    thickness: 1,
                    height: 20,
                    indent: 16,
                    endIndent: 16,
                  ),
                  Expanded(
                    child:
                        state.products.isEmpty
                            ? Center(
                              child: Text(
                                'home.no_products'.tr(),
                                style: AppFonts.styleRegular14.copyWith(
                                  color: AppColors.greyA4ACAD,
                                ),
                              ),
                            )
                            : CustomGridView<ProductModel>(
                              items: state.products,
                              itemBuilder:
                                  (context, product) =>
                                      HomeProductCard(product: product),
                            ),
                  ),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
