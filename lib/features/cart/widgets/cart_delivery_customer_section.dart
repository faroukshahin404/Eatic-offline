import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/custom_button_widget.dart';
import '../../../routes/app_paths.dart';
import '../../_main/cubit/main_cubit.dart';
import '../../customers/model/customer_address_row.dart';
import 'cart_selected_customer_card.dart';

class CartDeliveryCustomerSection extends StatelessWidget {
  const CartDeliveryCustomerSection({
    super.key,
    required this.selectedCustomer,
  });

  final CustomerAddressRow? selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final customer = selectedCustomer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomButtonWidget(
          text: customer == null
              ? 'cart.add_user_info'.tr()
              : 'cart.change_customer'.tr(),
          onPressed: () {
            context.read<MainCubit>().setCurrentScreen(
                  screen: AppPaths.customerSearch,
                );
          },
        ),
        if (customer != null) ...[
          const SizedBox(height: 12),
          CartSelectedCustomerCard(customer: customer),
        ],
      ],
    );
  }
}
