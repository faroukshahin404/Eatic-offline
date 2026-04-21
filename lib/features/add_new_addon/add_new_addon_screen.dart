import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import '../addons/model/addon_model.dart';
import 'cubit/add_new_addon_cubit.dart';
import 'widgets/add_new_addon_form_widget.dart';

/// Standalone addon form (e.g. legacy bottom sheet). Prefer inline flow on the addons screen.
class AddNewAddonScreen extends StatelessWidget {
  const AddNewAddonScreen({super.key, this.addon});
  final AddonModel? addon;

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocProvider<AddNewAddonCubit>(
        create: (context) {
          final cubit = getIt<AddNewAddonCubit>();
          cubit.setAddon(addon);
          return cubit;
        },
        child: BlocConsumer<AddNewAddonCubit, AddNewAddonState>(
          listener: (context, state) {
            if (state is AddNewAddonSaved) {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop<bool>(true);
              final message =
                  state.isUpdate
                      ? 'add_addon_form.update_success'.tr()
                      : 'add_addon_form.success'.tr();
              messenger.showSnackBar(
                SnackBar(content: Text(message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AddNewAddonSaving) {
              return const CustomLoading();
            }
            if (state is AddNewAddonError) {
              return CustomFailedWidget(
                message: state.message,
                onRetry: () => context.read<AddNewAddonCubit>().saveAddon(),
              );
            }
            return const AddNewAddonFormWidget();
          },
        ),
      ),
    );
  }
}
