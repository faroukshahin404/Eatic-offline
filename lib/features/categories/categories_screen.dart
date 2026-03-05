import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/platform_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../add_new_category/add_new_category_screen.dart';
import 'cubit/categories_cubit.dart';
import 'model/category_model.dart';
import 'widgets/list_of_categories_widget.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static Future<void> categoryDetails(
    BuildContext context, {
    CategoryModel? category,
  }) async {
    final result = await PlatformSheet.show(
      context: context,
      isScrollControlled: false,
      child: AddNewCategoryScreen(category: category),
    );
    if (result == true) {
      if (!(context.mounted)) return;
      context.read<CategoriesCubit>().getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'categories'),
      body: CustomPadding(
        child: BlocConsumer<CategoriesCubit, CategoriesState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const CustomLoading();
            }
            if (state is CategoriesError || state is CategoriesDeleteError) {
              final message = state is CategoriesError
                  ? state.message
                  : (state as CategoriesDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<CategoriesCubit>().getAll(),
              );
            }
            final categories =
                context.read<CategoriesCubit>().categories;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: 'add_category',
                  onPressed: () async {
                    categoryDetails(context);
                  },
                ),
                Expanded(
                  child: ListOfCategoriesWidget(
                    categories: categories,
                    onEdit: (item) =>
                        categoryDetails(context, category: item),
                    onDelete: (item) {
                      context
                          .read<CategoriesCubit>()
                          .deleteById(item.id!);
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
