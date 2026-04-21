import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/pos_crud_ui.dart';
import '../../services_locator/service_locator.dart';
import '../add_new_category/cubit/add_new_category_cubit.dart';
import '../add_new_category/widgets/add_new_category_form_widget.dart';
import 'cubit/categories_cubit.dart';
import 'model/category_model.dart';
import 'widgets/list_of_categories_widget.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _showForm = false;
  CategoryModel? _editCategory;
  int _formBlocKey = 0;

  void _openCreate() {
    setState(() {
      _showForm = true;
      _editCategory = null;
      _formBlocKey++;
    });
  }

  void _openEdit(CategoryModel category) {
    setState(() {
      _showForm = true;
      _editCategory = category;
      _formBlocKey++;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editCategory = null;
      _formBlocKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: 'categories'),
      body: CustomPadding(
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const CustomLoading();
            }
            if (state is CategoriesError || state is CategoriesDeleteError) {
              final message =
                  state is CategoriesError
                      ? state.message
                      : (state as CategoriesDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<CategoriesCubit>().getAll(),
              );
            }
            final categories = context.read<CategoriesCubit>().categories;

            return LayoutBuilder(
              builder: (context, constraints) {
                final maxFormHeight =
                    (constraints.maxHeight * 0.48).clamp(200.0, 420.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    SizedBox(
                      width: 220,
                      child: PosCrudActionButton(
                        label:
                            _showForm
                                ? 'dialog.cancel'.tr()
                                : 'add_category'.tr(),
                        icon:
                            _showForm
                                ? Icons.close_rounded
                                : Icons.category_outlined,
                        isPrimary: !_showForm,
                        onPressed: () {
                          if (_showForm) {
                            _closeForm();
                          } else {
                            _openCreate();
                          }
                        },
                      ),
                    ),
                    if (_showForm)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxFormHeight),
                        child: SingleChildScrollView(
                          child: BlocProvider<AddNewCategoryCubit>(
                            key: ValueKey(_formBlocKey),
                            create: (_) {
                              final cubit = getIt<AddNewCategoryCubit>();
                              cubit.setCategory(_editCategory);
                              cubit.loadCategories();
                              return cubit;
                            },
                            child: BlocConsumer<
                              AddNewCategoryCubit,
                              AddNewCategoryState
                            >(
                              listener: (context, formState) {
                                if (formState is AddNewCategorySaved) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        formState.isUpdate
                                            ? 'add_category_form.update_success'
                                                .tr()
                                            : 'add_category_form.success'
                                                .tr(),
                                      ),
                                    ),
                                  );
                                  _closeForm();
                                  context.read<CategoriesCubit>().getAll();
                                }
                              },
                              builder: (context, formState) {
                                if (formState is AddNewCategorySaving ||
                                    formState
                                        is AddNewCategoryLoadingCategories ||
                                    formState is AddNewCategoryInitial) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: CustomLoading()),
                                  );
                                }
                                if (formState is AddNewCategoryError) {
                                  return CustomFailedWidget(
                                    message: formState.message,
                                    onRetry:
                                        () => context
                                            .read<AddNewCategoryCubit>()
                                            .loadCategories(),
                                  );
                                }
                                if (formState
                                    is AddNewCategoryCategoriesLoaded) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.greyE6E9EA,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: AddNewCategoryFormWidget(),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListOfCategoriesWidget(
                        categories: categories,
                        onEdit: _openEdit,
                        onDelete: (item) {
                          context.read<CategoriesCubit>().deleteById(
                            item.id!,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
