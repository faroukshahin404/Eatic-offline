import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import '../categories/model/category_model.dart';
import 'cubit/add_new_category_cubit.dart';
import 'widgets/add_new_category_form_widget.dart';

class AddNewCategoryScreen extends StatelessWidget {
  const AddNewCategoryScreen({super.key, this.category});
  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocProvider<AddNewCategoryCubit>(
        create: (context) {
          final cubit = getIt<AddNewCategoryCubit>();
          cubit.setCategory(category);
          cubit.loadCategories();
          return cubit;
        },
        child: BlocConsumer<AddNewCategoryCubit, AddNewCategoryState>(
          listener: (context, state) {
            if (state is AddNewCategorySaved) {
              Navigator.of(context).pop<bool>(true);
              final message = state.isUpdate
                  ? 'add_category_form.update_success'.tr()
                  : 'add_category_form.success'.tr();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AddNewCategoryLoading) {
              return const CustomLoading();
            }
            if (state is AddNewCategoryError) {
              return CustomFailedWidget(
                message: state.message,
                onRetry: () =>
                    context.read<AddNewCategoryCubit>().loadCategories(),
              );
            }
            return const AddNewCategoryFormWidget();
          },
        ),
      ),
    );
  }
}
