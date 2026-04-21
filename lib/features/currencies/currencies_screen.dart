import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/pos_crud_ui.dart';
import '../../routes/app_paths.dart';
import 'cubit/currencies_cubit.dart';
import 'widgets/list_of_currencies_widget.dart';

class CurrenciesScreen extends StatelessWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: 'currencies'),
      body: CustomPadding(
        child: BlocBuilder<CurrenciesCubit, CurrenciesState>(
          builder: (context, state) {
            if (state is CurrenciesLoading) {
              return const CustomLoading();
            }
            if (state is CurrenciesError || state is CurrenciesDeleteError) {
              final message =
                  state is CurrenciesError
                      ? state.message
                      : (state as CurrenciesDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<CurrenciesCubit>().getAll(),
              );
            }
            final currencies = context.read<CurrenciesCubit>().currencies;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                SizedBox(
                  width: 220,
                  child: PosCrudActionButton(
                    label: 'add_currency'.tr(),
                    icon: Icons.currency_exchange_outlined,
                    onPressed: () async {
                      final result = await context.push<bool>(
                        AppPaths.addCurrency,
                      );
                      if (result == true && context.mounted) {
                        context.read<CurrenciesCubit>().getAll();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListOfCurrenciesWidget(
                    currencies: currencies,
                    onEdit: (item) async {
                      final result = await context.push<bool>(
                        AppPaths.addCurrency,
                        extra: item.id,
                      );
                      if (result == true && context.mounted) {
                        context.read<CurrenciesCubit>().getAll();
                      }
                    },
                    onDelete: (item) {
                      context.read<CurrenciesCubit>().deleteById(item.id!);
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
