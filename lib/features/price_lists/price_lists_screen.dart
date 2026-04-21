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
import '../add_new_price_list/cubit/add_new_price_list_cubit.dart';
import '../add_new_price_list/widgets/add_new_price_list_form_widget.dart';
import 'cubit/price_lists_cubit.dart';
import 'model/price_list_model.dart';
import 'widgets/list_of_price_lists_widget.dart';

class PriceListsScreen extends StatefulWidget {
  const PriceListsScreen({super.key});

  @override
  State<PriceListsScreen> createState() => _PriceListsScreenState();
}

class _PriceListsScreenState extends State<PriceListsScreen> {
  bool _showForm = false;
  PriceListModel? _editPriceList;
  int _formBlocKey = 0;

  void _openCreate() {
    setState(() {
      _showForm = true;
      _editPriceList = null;
      _formBlocKey++;
    });
  }

  void _openEdit(PriceListModel item) {
    setState(() {
      _showForm = true;
      _editPriceList = item;
      _formBlocKey++;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editPriceList = null;
      _formBlocKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: 'price_lists'),
      body: CustomPadding(
        child: BlocBuilder<PriceListsCubit, PriceListsState>(
          builder: (context, state) {
            if (state is PriceListsLoading) {
              return const CustomLoading();
            }
            if (state is PriceListsError || state is PriceListsDeleteError) {
              final message =
                  state is PriceListsError
                      ? state.message
                      : (state as PriceListsDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<PriceListsCubit>().getAll(),
              );
            }
            final priceLists = context.read<PriceListsCubit>().priceLists;

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
                                : 'add_price_list'.tr(),
                        icon:
                            _showForm
                                ? Icons.close_rounded
                                : Icons.price_change_outlined,
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
                          child: BlocProvider<AddNewPriceListCubit>(
                            key: ValueKey(_formBlocKey),
                            create: (_) {
                              final cubit = getIt<AddNewPriceListCubit>();
                              cubit.setPriceList(_editPriceList);
                              cubit.loadCurrencies();
                              return cubit;
                            },
                            child: BlocConsumer<
                              AddNewPriceListCubit,
                              AddNewPriceListState
                            >(
                              listener: (context, formState) {
                                if (formState is AddNewPriceListSaved) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        formState.isUpdate
                                            ? 'add_price_list_form.update_success'
                                                .tr()
                                            : 'add_price_list_form.success'
                                                .tr(),
                                      ),
                                    ),
                                  );
                                  _closeForm();
                                  context.read<PriceListsCubit>().getAll();
                                }
                              },
                              builder: (context, formState) {
                                if (formState is AddNewPriceListSaving ||
                                    formState
                                        is AddNewPriceListLoadingCurrencies ||
                                    formState is AddNewPriceListInitial) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(child: CustomLoading()),
                                  );
                                }
                                if (formState is AddNewPriceListError) {
                                  return CustomFailedWidget(
                                    message: formState.message,
                                    onRetry:
                                        () => context
                                            .read<AddNewPriceListCubit>()
                                            .loadCurrencies(),
                                  );
                                }
                                if (formState is AddNewPriceListReady) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.greyE6E9EA,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: AddNewPriceListFormWidget(),
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
                      child: ListOfPriceListsWidget(
                        priceLists: priceLists,
                        onEdit: _openEdit,
                        onDelete: (item) {
                          context.read<PriceListsCubit>().deleteById(
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
