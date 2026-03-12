import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text.dart';
import '../../customers/model/customer_address_row.dart';
import '../cubit/cart_cubit.dart';

class CartSelectedCustomerCard extends StatelessWidget {
  const CartSelectedCustomerCard({
    super.key,
    required this.customer,
  });

  final CustomerAddressRow customer;

  static String _str(String? v) => (v == null || v.trim().isEmpty) ? '-' : v;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greyE6E9EA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: '${'customers.name'.tr()}: ${_str(customer.name)}',
            needSelectable: true,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: '${'customers.phone'.tr()}: ${customer.phone}',
            needSelectable: true,
          ),
          const SizedBox(height: 4),
          CustomText(
            text:
                '${'customers.table.zone'.tr()}: ${_str(customer.zoneName)}',
            needSelectable: true,
          ),
          const SizedBox(height: 4),
          CustomText(
            text:
                '${'customers.table.building'.tr()}: ${_str(customer.buildingNumber)}',
            needSelectable: true,
          ),
          const SizedBox(height: 4),
          CustomText(
            text:
                '${'customers.table.floor'.tr()}: ${_str(customer.floor)}',
            needSelectable: true,
          ),
          const SizedBox(height: 4),
          CustomText(
            text:
                '${'customers.table.apartment'.tr()}: ${_str(customer.apartment)}',
            needSelectable: true,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                context.read<CartCubit>().setSelectedCustomer(null),
            child: Text('cart.clear_customer'.tr()),
          ),
        ],
      ),
    );
  }
}
