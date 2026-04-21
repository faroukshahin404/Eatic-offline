import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../../core/widgets/custom_text.dart';
import '../../dining_areas/model/dining_area_model.dart';
import '../cubit/add_new_restaurant_table_cubit.dart';

class RestaurantTableDiningAreaDropdownWidget extends StatelessWidget {
  const RestaurantTableDiningAreaDropdownWidget({
    super.key,
    required this.cubit,
  });

  final AddNewRestaurantTableCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewRestaurantTableCubit, AddNewRestaurantTableState>(
      builder: (context, state) {
        final selectedBranch = cubit.selectedBranch;
        if (selectedBranch == null) {
          return const SizedBox.shrink();
        }

        if (state is AddNewRestaurantTableLoadingDiningAreas) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'add_restaurant_table_form.dining_area'.tr(),
                style: AppFonts.styleMedium18.copyWith(
                  color: AppColors.oppositeColor,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    CustomText(
                        text: 'add_restaurant_table_form.loading_dining_areas'.tr()),
                  ],
                ),
              ),
            ],
          );
        }

        if (state is AddNewRestaurantTableDiningAreasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'add_restaurant_table_form.dining_area'.tr(),
                style: AppFonts.styleMedium18.copyWith(
                  color: AppColors.oppositeColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomText(
                        text: state.message,
                        style: TextStyle(
                            color: Colors.red.shade800, fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () => cubit
                          .loadDiningAreasForBranch(selectedBranch.id!),
                      child: Text('retry_button'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return CustomDropDown<DiningAreaModel>(
          items: cubit.diningAreas,
          value: cubit.selectedDiningArea,
          onChanged: cubit.setSelectedDiningArea,
          itemLabelBuilder: (d) => d.name ?? '-',
          label: 'add_restaurant_table_form.dining_area'.tr(),
          leadingIcon: Icons.dining_outlined,
          validator: (v) => v == null ? 'validation.required'.tr() : null,
          hideWhenEmpty: false,
          emptyMessage: 'add_restaurant_table_form.no_dining_areas'.tr(),
        );
      },
    );
  }
}
