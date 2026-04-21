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
import '../add_new_dining_area/cubit/add_new_dining_area_cubit.dart';
import '../add_new_dining_area/widgets/add_new_dining_area_form_widget.dart';
import 'cubit/dining_areas_cubit.dart';
import 'model/dining_area_model.dart';
import 'widgets/list_of_dining_areas_widget.dart';

class DiningAreasScreen extends StatefulWidget {
  const DiningAreasScreen({super.key});

  @override
  State<DiningAreasScreen> createState() => _DiningAreasScreenState();
}

class _DiningAreasScreenState extends State<DiningAreasScreen> {
  bool _showForm = false;
  DiningAreaModel? _editArea;
  int _formBlocKey = 0;

  void _openCreate() {
    setState(() {
      _showForm = true;
      _editArea = null;
      _formBlocKey++;
    });
  }

  void _openEdit(DiningAreaModel area) {
    setState(() {
      _showForm = true;
      _editArea = area;
      _formBlocKey++;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editArea = null;
      _formBlocKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: 'dining_areas'),
      body: CustomPadding(
        child: BlocBuilder<DiningAreasCubit, DiningAreasState>(
          builder: (context, state) {
            if (state is DiningAreasLoading) {
              return const CustomLoading();
            }
            if (state is DiningAreasError || state is DiningAreasDeleteError) {
              final message =
                  state is DiningAreasError
                      ? state.message
                      : (state as DiningAreasDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<DiningAreasCubit>().getAll(),
              );
            }
            final diningAreas = context.read<DiningAreasCubit>().diningAreas;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 220,
                      child: PosCrudActionButton(
                        label:
                            _showForm
                                ? 'dialog.cancel'.tr()
                                : 'add_dining_area'.tr(),
                        icon:
                            _showForm
                                ? Icons.close_rounded
                                : Icons.dining_outlined,
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
                  ],
                ),
                if (_showForm)
                  BlocProvider<AddNewDiningAreaCubit>(
                    key: ValueKey(_formBlocKey),
                    create: (_) {
                      final cubit = getIt<AddNewDiningAreaCubit>();
                      cubit.setDiningArea(_editArea);
                      cubit.loadBranches();
                      return cubit;
                    },
                    child: BlocConsumer<
                      AddNewDiningAreaCubit,
                      AddNewDiningAreaState
                    >(
                      listener: (context, formState) {
                        if (formState is AddNewDiningAreaSaved) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                formState.isUpdate
                                    ? 'add_dining_area_form.update_success'.tr()
                                    : 'add_dining_area_form.success'.tr(),
                              ),
                            ),
                          );
                          _closeForm();
                          context.read<DiningAreasCubit>().getAll();
                        }
                      },
                      builder: (context, formState) {
                        if (formState is AddNewDiningAreaLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CustomLoading()),
                          );
                        }
                        if (formState is AddNewDiningAreaError) {
                          return CustomFailedWidget(
                            message: formState.message,
                            onRetry:
                                () =>
                                    context
                                        .read<AddNewDiningAreaCubit>()
                                        .loadBranches(),
                          );
                        }
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.greyE6E9EA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: AddNewDiningAreaFormWidget(),
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: ListOfDiningAreasWidget(
                    diningAreas: diningAreas,
                    onEdit: _openEdit,
                    onDelete: (item) {
                      context.read<DiningAreasCubit>().deleteById(item.id!);
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
