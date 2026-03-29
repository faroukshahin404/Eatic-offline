import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import 'cubit/add_new_zone_cubit.dart';
import 'widgets/add_new_zone_form_widget.dart';

class AddNewZoneScreen extends StatelessWidget {
  const AddNewZoneScreen({super.key, this.zoneId});

  /// When non-null, opens in edit mode and loads this zone to display in the form.
  final int? zoneId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'add_zone'),
      body: CustomPadding(
        child: BlocProvider<AddNewZoneCubit>(
          create: (context) {
            final cubit = getIt<AddNewZoneCubit>();
            if (zoneId != null) cubit.setZoneIdForEdit(zoneId!);
            cubit.loadBranches();
            return cubit;
          },
          child: BlocConsumer<AddNewZoneCubit, AddNewZoneState>(
            listener: (context, state) {
              if (state is AddNewZoneSaved) {
                final messenger = ScaffoldMessenger.of(context);
                context.pop<bool>(true);
                final message = state.isUpdate
                    ? 'add_zone_form.update_success'.tr()
                    : 'add_zone_form.success'.tr();
                messenger.showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
            builder: (context, state) {
              if (state is AddNewZoneLoading) {
                return const CustomLoading();
              }
              if (state is AddNewZoneError) {
                return CustomFailedWidget(
                  message: state.message,
                  onRetry: () => context.read<AddNewZoneCubit>().loadBranches(),
                );
              }
              return const AddNewZoneFormWidget();
            },
          ),
        ),
      ),
    );
  }
}
