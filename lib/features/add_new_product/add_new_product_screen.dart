import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_utils.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/add_new_product_cubit.dart';
import 'widgets/add_new_product_form_widget.dart';

class AddNewProductScreen extends StatelessWidget {
  const AddNewProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'add_product'),
      body: BlocConsumer<AddNewProductCubit, AddNewProductState>(
        listener: (context, state) {
          if (state is AddNewProductSaved) {
            final message = 'add_product_form.success'.tr();
            if (context.mounted) {
              context.pop<bool>(true);
            } else {
              AppUtils.navigatorKey.currentState?.pop(true);
            }
            // Show after pop: a SnackBar queued before pop stays tied to the
            // disposed route's scaffolds and breaks on animation callbacks.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final root = AppUtils.navigatorKey.currentContext;
              if (root == null || !root.mounted) return;
              ScaffoldMessenger.of(root).showSnackBar(
                SnackBar(content: Text(message)),
              );
            });
          }
        },
        builder: (context, state) {
          if (state is AddNewProductLoading) {
            return const CustomLoading();
          }
          if (state is AddNewProductError) {
            return CustomFailedWidget(
              message: state.message,
              onRetry:
                  () => context.read<AddNewProductCubit>().loadData(
                    productId: context.read<AddNewProductCubit>().productId,
                  ),
            );
          }
          return CustomPadding(child: AddNewProductFormWidget());
        },
      ),
    );
  }
}
