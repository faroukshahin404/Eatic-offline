import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../_main/cubit/main_cubit.dart';
import '../cubit/cart_cubit.dart';
import '../../customers/model/customer_address_row.dart';

class CartDeliveryCustomerSection extends StatelessWidget {
  const CartDeliveryCustomerSection({
    super.key,
    required this.selectedCustomer,
  });

  final CustomerAddressRow? selectedCustomer;

  String _customerButtonText(CustomerAddressRow? customer) {
    if (customer == null) return 'cart.add_user_info'.tr();
    final name = customer.name?.trim();
    final displayName = (name == null || name.isEmpty) ? '-' : name;
    return '${'cart.change_customer'.tr()} ($displayName - ${customer.phone})';
  }

  void _onCustomerButtonPressed(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    if (selectedCustomer != null) {
      cartCubit.clearSelectedCustomerFlow();
    }
    context.read<MainCubit>().setCustomerInfoPanelVisible(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      buildWhen:
          (p, c) => p.customerInfoPanelVisible != c.customerInfoPanelVisible,
      builder: (context, state) {
        return Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _onCustomerButtonPressed(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                _customerButtonText(selectedCustomer),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
