import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../routes/app_paths.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/currencies_cubit.dart';
import 'widgets/list_of_currencies_widget.dart';

class CurrenciesScreen extends StatelessWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'currencies'),
      body: CustomPadding(
        child: BlocConsumer<CurrenciesCubit, CurrenciesState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is CurrenciesLoading) {
              return const CustomLoading();
            }
            if (state is CurrenciesError || state is CurrenciesDeleteError) {
              final message = state is CurrenciesError
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
                CustomButtonWidget(
                  text: 'add_currency',
                  onPressed: () async {
                    final result =
                        await context.push<bool>(AppPaths.addCurrency);
                    if (result == true && context.mounted) {
                      context.read<CurrenciesCubit>().getAll();
                    }
                  },
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
