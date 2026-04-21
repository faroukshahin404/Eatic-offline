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
import '../add_new_payment_method/cubit/add_new_payment_method_cubit.dart';
import '../add_new_payment_method/widgets/add_new_payment_method_form_widget.dart';
import 'cubit/payment_methods_cubit.dart';
import 'model/payment_method_model.dart';
import 'widgets/list_of_payment_methods_widget.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _showForm = false;
  PaymentMethodModel? _editMethod;
  int _formBlocKey = 0;

  void _openCreate() {
    setState(() {
      _showForm = true;
      _editMethod = null;
      _formBlocKey++;
    });
  }

  void _openEdit(PaymentMethodModel method) {
    setState(() {
      _showForm = true;
      _editMethod = method;
      _formBlocKey++;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editMethod = null;
      _formBlocKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: 'payment_methods'),
      body: CustomPadding(
        child: BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
          builder: (context, state) {
            if (state is PaymentMethodsLoading) {
              return const CustomLoading();
            }
            if (state is PaymentMethodsError ||
                state is PaymentMethodsDeleteError) {
              final message =
                  state is PaymentMethodsError
                      ? state.message
                      : (state as PaymentMethodsDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<PaymentMethodsCubit>().getAll(),
              );
            }
            final paymentMethods =
                context.read<PaymentMethodsCubit>().paymentMethods;
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
                                : 'add_payment_method'.tr(),
                        icon:
                            _showForm
                                ? Icons.close_rounded
                                : Icons.payment_rounded,
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
                  BlocProvider<AddNewPaymentMethodCubit>(
                    key: ValueKey(_formBlocKey),
                    create:
                        (_) =>
                            getIt<AddNewPaymentMethodCubit>()
                              ..setPaymentMethod(_editMethod),
                    child: BlocConsumer<
                      AddNewPaymentMethodCubit,
                      AddNewPaymentMethodState
                    >(
                      listener: (context, formState) {
                        if (formState is AddNewPaymentMethodSaved) {
                          final wasEdit = _editMethod != null;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                wasEdit
                                    ? 'add_payment_method_form.update_success'
                                        .tr()
                                    : 'add_payment_method_form.success'.tr(),
                              ),
                            ),
                          );
                          _closeForm();
                          context.read<PaymentMethodsCubit>().getAll();
                        }
                      },
                      builder: (context, formState) {
                        if (formState is AddNewPaymentMethodLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CustomLoading()),
                          );
                        }
                        if (formState is AddNewPaymentMethodError) {
                          return CustomFailedWidget(
                            message: formState.message,
                            onRetry:
                                () =>
                                    context
                                        .read<AddNewPaymentMethodCubit>()
                                        .dismissError(),
                          );
                        }
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.greyE6E9EA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: AddNewPaymentMethodFormWidget(),
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: ListOfPaymentMethodsWidget(
                    paymentMethods: paymentMethods,
                    onEdit: _openEdit,
                    onDelete: (item) {
                      context.read<PaymentMethodsCubit>().deleteById(item.id!);
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
