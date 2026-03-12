import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_header_screen.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../routes/app_paths.dart';
import 'cubit/add_customer_cubit.dart';
import 'widgets/add_customer_form_widget.dart';

class AddCustomerScreen extends StatelessWidget {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocConsumer<AddCustomerCubit, AddCustomerState>(
        listener: (context, state) {
          if (state is AddCustomerSaved) {
            context.pop<bool>(true);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('customers.save'.tr())));
          }
        },
        builder: (context, state) {
          if (state is AddCustomerLoading &&
              context.read<AddCustomerCubit>().zones.isEmpty) {
            return const CustomLoading();
          }
          if (state is AddCustomerError) {
            return CustomFailedWidget(
              message: state.message,
              onRetry: () => context.read<AddCustomerCubit>().loadZones(),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeaderScreen(
                title: 'customers.add_customer'.tr(),
                path: AppPaths.customerSearch,
              ),
              const SizedBox(height: 16),
              const Expanded(child: AddCustomerFormWidget()),
            ],
          );
        },
      ),
    );
  }
}
