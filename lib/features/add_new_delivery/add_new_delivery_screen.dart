import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/add_new_delivery_cubit.dart';
import 'widgets/add_new_delivery_form_widget.dart';

class AddNewDeliveryScreen extends StatelessWidget {
  const AddNewDeliveryScreen({super.key, this.deliveryId});

  /// When non-null, opens in edit mode and loads this delivery to display in the form.
  final int? deliveryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'add_delivery'),
      body: CustomPadding(
        child: BlocConsumer<AddNewDeliveryCubit, AddNewDeliveryState>(
          listener: (context, state) {
            if (state is AddNewDeliverySaved) {
              context.pop<bool>(true);
              final message = state.isUpdate
                  ? 'add_delivery_form.update_success'.tr()
                  : 'add_delivery_form.success'.tr();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) {
            if (state is AddNewDeliveryLoading) {
              return const CustomLoading();
            }
            if (state is AddNewDeliveryError) {
              return CustomFailedWidget(
                message: state.message,
                onRetry: () =>
                    context.read<AddNewDeliveryCubit>().loadBranches(),
              );
            }
            return const AddNewDeliveryFormWidget();
          },
        ),
      ),
    );
  }
}
