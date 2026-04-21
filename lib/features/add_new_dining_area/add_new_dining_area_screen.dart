import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import '../dining_areas/model/dining_area_model.dart';
import 'cubit/add_new_dining_area_cubit.dart';
import 'widgets/add_new_dining_area_form_widget.dart';

/// Standalone dining area form (e.g. legacy bottom sheet). Prefer inline flow on [DiningAreasScreen].
class AddNewDiningAreaScreen extends StatelessWidget {
  const AddNewDiningAreaScreen({super.key, this.diningArea});
  final DiningAreaModel? diningArea;

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocProvider<AddNewDiningAreaCubit>(
        create: (context) {
          final cubit = getIt<AddNewDiningAreaCubit>();
          cubit.setDiningArea(diningArea);
          cubit.loadBranches();
          return cubit;
        },
        child: BlocConsumer<AddNewDiningAreaCubit, AddNewDiningAreaState>(
          listener: (context, state) {
            if (state is AddNewDiningAreaSaved) {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop<bool>(true);
              final message =
                  state.isUpdate
                      ? 'add_dining_area_form.update_success'.tr()
                      : 'add_dining_area_form.success'.tr();
              messenger.showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (context, state) {
            if (state is AddNewDiningAreaLoading) {
              return const CustomLoading();
            }
            if (state is AddNewDiningAreaError) {
              return CustomFailedWidget(
                message: state.message,
                onRetry:
                    () => context.read<AddNewDiningAreaCubit>().loadBranches(),
              );
            }
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyE6E9EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: AddNewDiningAreaFormWidget(),
              ),
            );
          },
        ),
      ),
    );
  }
}
