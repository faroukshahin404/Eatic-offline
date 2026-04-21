import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_dropdown.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/pos_crud_ui.dart';
import '../../services_locator/service_locator.dart';
import '../add_new_restaurant_table/cubit/add_new_restaurant_table_cubit.dart';
import '../add_new_restaurant_table/widgets/add_new_restaurant_table_form_widget.dart';
import 'cubit/restaurant_tables_cubit.dart';
import 'model/restaurant_table_model.dart';
import 'widgets/list_of_restaurant_tables_widget.dart';

class RestaurantTablesScreen extends StatefulWidget {
  const RestaurantTablesScreen({super.key});

  @override
  State<RestaurantTablesScreen> createState() => _RestaurantTablesScreenState();
}

class _RestaurantTablesScreenState extends State<RestaurantTablesScreen> {
  int? _filterBranchId;
  bool _showForm = false;
  RestaurantTableModel? _editTable;
  int _formBlocKey = 0;

  static List<MapEntry<int, String>> _branchOptions(
    List<RestaurantTableModel> tables,
  ) {
    final m = <int, String>{};
    for (final t in tables) {
      if (t.branchId != null) {
        m[t.branchId!] = t.branchName ?? '#${t.branchId}';
      }
    }
    final list =
        m.entries.toList()..sort(
          (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()),
        );
    return list;
  }

  void _openCreate() {
    setState(() {
      _showForm = true;
      _editTable = null;
      _formBlocKey++;
    });
  }

  void _openEdit(RestaurantTableModel table) {
    setState(() {
      _showForm = true;
      _editTable = table;
      _formBlocKey++;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editTable = null;
      _formBlocKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: 'restaurant_tables'),
      body: CustomPadding(
        child: BlocBuilder<RestaurantTablesCubit, RestaurantTablesState>(
          builder: (context, state) {
            if (state is RestaurantTablesLoading) {
              return const CustomLoading();
            }
            if (state is RestaurantTablesError ||
                state is RestaurantTablesDeleteError) {
              final message =
                  state is RestaurantTablesError
                      ? state.message
                      : (state as RestaurantTablesDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<RestaurantTablesCubit>().getAll(),
              );
            }
            final restaurantTables =
                context.read<RestaurantTablesCubit>().restaurantTables;
            final branchOpts = _branchOptions(restaurantTables);
            final branchLabels = {for (final e in branchOpts) e.key: e.value};

            return LayoutBuilder(
              builder: (context, constraints) {
                final maxFormHeight =
                    (constraints.maxHeight * 0.48).clamp(160.0, 380.0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          child: PosCrudActionButton(
                            label:
                                _showForm
                                    ? 'dialog.cancel'.tr()
                                    : 'add_restaurant_table'.tr(),
                            icon:
                                _showForm
                                    ? Icons.close_rounded
                                    : Icons.table_restaurant_outlined,
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
                        if (branchOpts.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 200,
                                ),
                                child: CustomDropDown<int?>(
                                  items: [
                                    null,
                                    ...branchOpts.map((e) => e.key),
                                  ],
                                  value: _filterBranchId,
                                  onChanged:
                                      (v) =>
                                          setState(() => _filterBranchId = v),
                                  itemLabelBuilder:
                                      (id) =>
                                          id == null
                                              ? 'home.all'.tr()
                                              : (branchLabels[id] ?? '$id'),
                                  hint: 'add_restaurant_table_form.branch'.tr(),
                                  leadingIcon: Icons.filter_alt_outlined,
                                  compact: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_showForm)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxFormHeight),
                        child: SingleChildScrollView(
                          child: BlocProvider<AddNewRestaurantTableCubit>(
                            key: ValueKey(_formBlocKey),
                            create: (_) {
                              final cubit = getIt<AddNewRestaurantTableCubit>();
                              cubit.setRestaurantTable(_editTable);
                              cubit.loadBranches();
                              return cubit;
                            },
                            child: BlocConsumer<
                              AddNewRestaurantTableCubit,
                              AddNewRestaurantTableState
                            >(
                              listener: (context, formState) {
                                if (formState is AddNewRestaurantTableSaved) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        formState.isUpdate
                                            ? 'add_restaurant_table_form.update_success'
                                                .tr()
                                            : 'add_restaurant_table_form.success'
                                                .tr(),
                                      ),
                                    ),
                                  );
                                  _closeForm();
                                  context.read<RestaurantTablesCubit>().getAll();
                                }
                              },
                              builder: (context, formState) {
                                if (formState is AddNewRestaurantTableSaving) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: CustomLoading()),
                                  );
                                }
                                if (formState is AddNewRestaurantTableError) {
                                  return CustomFailedWidget(
                                    message: formState.message,
                                    onRetry:
                                        () => context
                                            .read<AddNewRestaurantTableCubit>()
                                            .loadBranches(),
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
                                    child: AddNewRestaurantTableFormWidget(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListOfRestaurantTablesWidget(
                        restaurantTables: restaurantTables,
                        filterBranchId: _filterBranchId,
                        onEdit: _openEdit,
                        onDelete: (item) {
                          context.read<RestaurantTablesCubit>().deleteById(
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
