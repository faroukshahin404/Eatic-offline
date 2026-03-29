import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../routes/app_paths.dart';
import 'cubit/products_cubit.dart';
import 'cubit/products_state.dart';
import 'widgets/list_of_products_widget.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'products'),
      body: CustomPadding(
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return const CustomLoading();
            }
            if (state is ProductsError || state is ProductsDeleteError) {
              final message = state is ProductsError
                  ? state.message
                  : (state as ProductsDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<ProductsCubit>().loadProducts(),
              );
            }
            final products = context.read<ProductsCubit>().products;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomButtonWidget(
                  text: 'add_product',
                  onPressed: () async {
                    final result = await context.push<bool>(AppPaths.addProduct);
                    if (context.mounted && result == true) {
                      context.read<ProductsCubit>().loadProducts();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListOfProductsWidget(
                    products: products,
                    onEdit: (product) async {
                      final id = product.id;
                      if (id == null) return;
                      final result = await context.push<bool>(
                        AppPaths.addProduct,
                        extra: id,
                      );
                      if (context.mounted && result == true) {
                        context.read<ProductsCubit>().loadProducts();
                      }
                    },
                    onDelete: (product) async {
                      final id = product.id;
                      if (id == null) return;
                      final name = product.name ?? product.nameEn ?? '-';
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('actions.delete'.tr()),
                          content: Text(
                            'products.delete_confirm'.tr(
                              namedArgs: {'name': name},
                            ),
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
                        context.read<ProductsCubit>().deleteProduct(id);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
