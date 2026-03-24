import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/shift_details_cubit.dart';
import 'widgets/item_details_widget.dart';

class ShiftDetailsScreen extends StatelessWidget {
  const ShiftDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'shift_details'),
      body: BlocBuilder<ShiftDetailsCubit, ShiftDetailsState>(
        builder: (context, state) {
          if (state is ShiftDetailsLoading) {
            return const CustomLoading();
          }
          if (state is ShiftDetailsError) {
            return CustomFailedWidget(message: state.message);
          }
          final cubit = context.read<ShiftDetailsCubit>();
          return CustomPadding(
            child: ListView.separated(
              itemCount: cubit.paymentMethods.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 40,
                    color: AppColors.greyA4ACAD,
                    thickness: 1,
                  ),
              itemBuilder: (context, paymentMethodIndex) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      cubit.paymentMethods[paymentMethodIndex].name ?? '',
                      style: AppFonts.styleBold24.copyWith(
                        fontFamily: AppFonts.enFamily,
                      ),
                    ),
                    ListView.separated(
                      itemCount: cubit.orderTypes.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 10),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, orderTypeIndex) {
                        return ItemDetailsWidget(
                          orderTypeName:
                              "${cubit.orderTypes[orderTypeIndex].name.tr()} (${cubit.paymentMethods[paymentMethodIndex].name ?? ''})",

                          paymentMethodId:
                              cubit.paymentMethods[paymentMethodIndex].id ?? 0,
                          orderType: cubit.orderTypes[orderTypeIndex].id ?? 0,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
