import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../branches/model/branch_model.dart';
import '../cubit/add_new_delivery_cubit.dart';

class BranchDropdownWidget extends StatelessWidget {
  const BranchDropdownWidget({super.key, required this.cubit});

  final AddNewDeliveryCubit cubit;

  static InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.mainColor),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      filled: true,
      fillColor: AppColors.fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewDeliveryCubit, AddNewDeliveryState>(
      builder: (context, state) {
        final branches = cubit.branches;
        final selected = cubit.selectedBranch;
        if (branches.isEmpty) {
          return const SizedBox.shrink();
        }
        final value = selected ?? branches.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'add_delivery_form.branch'.tr(),
              textAlign: TextAlign.start,
              style: AppFonts.styleMedium18.copyWith(
                color: AppColors.oppositeColor,
              ),
            ),
            const SizedBox(height: 5),
            DropdownButtonFormField<BranchModel>(
              value: value,
              decoration: _dropdownDecoration(),
              dropdownColor: AppColors.fillColor,
              style: AppFonts.styleRegular18.copyWith(
                color: AppColors.oppositeColor,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.greyA4ACAD,
              ),
              isExpanded: true,
              items: branches
                  .map(
                    (b) => DropdownMenuItem<BranchModel>(
                      value: b,
                      child: Text(
                        b.name,
                        style: AppFonts.styleRegular18.copyWith(
                          fontFamily: AppFonts.enFamily,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (BranchModel? value) => cubit.setSelectedBranch(value),
              validator: (BranchModel? v) =>
                  v == null ? 'validation.required'.tr() : null,
            ),
          ],
        );
      },
    );
  }
}
