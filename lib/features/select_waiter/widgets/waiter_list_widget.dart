import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../users/model/user_model.dart';
import '../cubit/select_waiter_cubit.dart';

/// List of waiters with radio single selection.
class WaiterListWidget extends StatelessWidget {
  const WaiterListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectWaiterCubit, SelectWaiterState>(
      builder: (context, state) {
        final cubit = context.read<SelectWaiterCubit>();
        final waiters = cubit.waiters;
        final selected = cubit.selectedWaiter;

        if (waiters.isEmpty) {
          return Center(
            child: Text(
              'table.no_users'.tr(),
              style: TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: waiters.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final waiter = waiters[index];
            final isSelected = selected?.id == waiter.id;
            return RadioListTile<UserModel>(
              value: waiter,
              groupValue: selected,
              onChanged: (UserModel? value) => cubit.setSelectedWaiter(value),
              title: Text(
                waiter.name ?? waiter.code,
                style: const TextStyle(
                  color: AppColors.oppositeColor,
                  fontSize: 16,
                ),
              ),
              subtitle: waiter.name != null && waiter.name != waiter.code
                  ? Text(
                      waiter.code,
                      style: TextStyle(
                        color: AppColors.greyA4ACAD,
                        fontSize: 14,
                      ),
                    )
                  : null,
              activeColor: AppColors.mainColor,
            );
          },
        );
      },
    );
  }
}
