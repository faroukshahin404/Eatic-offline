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
import '../add_new_addon/cubit/add_new_addon_cubit.dart';
import '../add_new_addon/widgets/add_new_addon_form_widget.dart';
import 'cubit/addons_cubit.dart';
import 'model/addon_model.dart';
import 'widgets/list_of_addons_widget.dart';

class AddonsScreen extends StatefulWidget {
  const AddonsScreen({super.key});

  @override
  State<AddonsScreen> createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  bool _showForm = false;
  AddonModel? _editAddon;
  int _formBlocKey = 0;

  void _openCreate() {
    setState(() {
      _showForm = true;
      _editAddon = null;
      _formBlocKey++;
    });
  }

  void _openEdit(AddonModel addon) {
    setState(() {
      _showForm = true;
      _editAddon = addon;
      _formBlocKey++;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editAddon = null;
      _formBlocKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: 'addons'),
      body: CustomPadding(
        child: BlocBuilder<AddonsCubit, AddonsState>(
          builder: (context, state) {
            if (state is AddonsLoading) {
              return const CustomLoading();
            }
            if (state is AddonsError || state is AddonsDeleteError) {
              final message =
                  state is AddonsError
                      ? state.message
                      : (state as AddonsDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<AddonsCubit>().getAll(),
              );
            }
            final addons = context.read<AddonsCubit>().addons;

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
                                : 'add_addon'.tr(),
                        icon:
                            _showForm
                                ? Icons.close_rounded
                                : Icons.extension_outlined,
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
                          child: BlocProvider<AddNewAddonCubit>(
                            key: ValueKey(_formBlocKey),
                            create: (_) {
                              final cubit = getIt<AddNewAddonCubit>();
                              cubit.setAddon(_editAddon);
                              return cubit;
                            },
                            child: BlocConsumer<AddNewAddonCubit, AddNewAddonState>(
                              listener: (context, formState) {
                                if (formState is AddNewAddonSaved) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        formState.isUpdate
                                            ? 'add_addon_form.update_success'
                                                .tr()
                                            : 'add_addon_form.success'.tr(),
                                      ),
                                    ),
                                  );
                                  _closeForm();
                                  context.read<AddonsCubit>().getAll();
                                }
                              },
                              builder: (context, formState) {
                                if (formState is AddNewAddonSaving) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: CustomLoading()),
                                  );
                                }
                                if (formState is AddNewAddonError) {
                                  return CustomFailedWidget(
                                    message: formState.message,
                                    onRetry:
                                        () => context
                                            .read<AddNewAddonCubit>()
                                            .saveAddon(),
                                  );
                                }
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.greyE6E9EA,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: AddNewAddonFormWidget(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListOfAddonsWidget(
                        addons: addons,
                        onEdit: _openEdit,
                        onDelete: (item) {
                          context.read<AddonsCubit>().deleteById(item.id!);
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
