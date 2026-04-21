import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import 'cubit/add_new_currency_cubit.dart';
import 'widgets/add_new_currency_form_widget.dart';

class AddNewCurrencyScreen extends StatelessWidget {
  const AddNewCurrencyScreen({super.key, this.currencyId});

  /// When non-null, opens in edit mode and loads this currency to display in the form.
  final int? currencyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: 'add_currency'),
      body: CustomPadding(
        child: BlocProvider<AddNewCurrencyCubit>(
          create: (context) {
            final cubit = getIt<AddNewCurrencyCubit>();
            if (currencyId != null) cubit.setCurrencyIdForEdit(currencyId!);
            cubit.load();
            return cubit;
          },
          child: BlocConsumer<AddNewCurrencyCubit, AddNewCurrencyState>(
            listener: (context, state) {
              if (state is AddNewCurrencySaved) {
                final messenger = ScaffoldMessenger.of(context);
                context.pop<bool>(true);
                final message =
                    state.isUpdate
                        ? 'add_currency_form.update_success'.tr()
                        : 'add_currency_form.success'.tr();
                messenger.showSnackBar(SnackBar(content: Text(message)));
              }
            },
            builder: (context, state) {
              if (state is AddNewCurrencyLoading) {
                return const CustomLoading();
              }
              if (state is AddNewCurrencyError) {
                return CustomFailedWidget(
                  message: state.message,
                  onRetry: () => context.read<AddNewCurrencyCubit>().load(),
                );
              }
              return DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyE6E9EA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AddNewCurrencyFormWidget(),
              );
            },
          ),
        ),
      ),
    );
  }
}
