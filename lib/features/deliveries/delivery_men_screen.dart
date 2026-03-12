import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../routes/app_paths.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/delivery_men_cubit.dart';
import 'widgets/list_of_delivery_men_widget.dart';

class DeliveryMenScreen extends StatelessWidget {
  const DeliveryMenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'delivery_men'),
      body: CustomPadding(
        child: BlocConsumer<DeliveryMenCubit, DeliveryMenState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is DeliveryMenLoading) {
              return const CustomLoading();
            }
            if (state is DeliveryMenError || state is DeliveryMenDeleteError) {
              final message = state is DeliveryMenError
                  ? state.message
                  : (state as DeliveryMenDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<DeliveryMenCubit>().getAll(),
              );
            }
            final deliveryMen = context.read<DeliveryMenCubit>().deliveryMen;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: 'add_delivery',
                  onPressed: () async {
                    final result = await context.push<bool>(AppPaths.addDelivery);
                    if (result == true && context.mounted) {
                      context.read<DeliveryMenCubit>().getAll();
                    }
                  },
                ),
                Expanded(
                  child: ListOfDeliveryMenWidget(
                    deliveryMen: deliveryMen,
                    onEdit: (item) async {
                      final result = await context.push<bool>(
                        AppPaths.addDelivery,
                        extra: item.id,
                      );
                      if (result == true && context.mounted) {
                        context.read<DeliveryMenCubit>().getAll();
                      }
                    },
                    onDelete: (item) {
                      context.read<DeliveryMenCubit>().deleteById(item.id!);
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
