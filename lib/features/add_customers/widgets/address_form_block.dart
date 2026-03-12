import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../zones/model/zone_model.dart';
import '../cubit/add_customer_cubit.dart';

/// Single address block: Zone dropdown, apartment, floor, building number, is_default, remove button.
class AddressFormBlock extends StatelessWidget {
  const AddressFormBlock({
    super.key,
    required this.index,
    required this.entry,
    required this.canRemove,
  });

  final int index;
  final AddressFormEntry entry;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddCustomerCubit>();
    final zones = cubit.zones;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyE6E9EA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${'customers.add_new_address'.tr()} (${index + 1})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.oppositeColor,
                ),
              ),
              if (canRemove) ...[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.validationError),
                  onPressed: () => cubit.removeAddress(index),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          CustomDropDown<ZoneModel?>(
            items: zones.isEmpty ? [null] : [null, ...zones],
            value: entry.selectedZone,
            onChanged: (z) => cubit.setAddressZone(index, z),
            itemLabelBuilder: (z) => z?.name ?? 'customers.zone'.tr(),
            label: 'customers.zone'.tr(),
            validator: (v) =>
                v == null ? 'validation.required'.tr() : null,
            hideWhenEmpty: false,
            emptyMessage: zones.isEmpty
                ? 'customers.validation.zone_required'.tr()
                : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            title: 'customers.apartment'.tr(),
            hint: 'customers.apartment'.tr(),
            controller: entry.apartmentController,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            title: 'customers.floor'.tr(),
            hint: 'customers.floor'.tr(),
            controller: entry.floorController,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            title: 'customers.building_number'.tr(),
            hint: 'customers.building_number'.tr(),
            controller: entry.buildingNumberController,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: entry.isDefault,
            onChanged: (v) => cubit.setAddressIsDefault(index, v ?? false),
            title: Text(
              'customers.is_default'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.oppositeColor,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
