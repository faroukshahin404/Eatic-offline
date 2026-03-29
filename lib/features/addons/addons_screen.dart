import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/platform_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../add_new_addon/add_new_addon_screen.dart';
import 'cubit/addons_cubit.dart';
import 'model/addon_model.dart';
import 'widgets/list_of_addons_widget.dart';

class AddonsScreen extends StatelessWidget {
  const AddonsScreen({super.key});

  static Future<void> addonDetails(
    BuildContext context, {
    AddonModel? addon,
  }) async {
    final result = await PlatformSheet.show(
      context: context,
      isScrollControlled: false,
      child: AddNewAddonScreen(addon: addon),
    );
    if (result == true) {
      if (!(context.mounted)) return;
      context.read<AddonsCubit>().getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'addons'),
      body: CustomPadding(
        child: BlocBuilder<AddonsCubit, AddonsState>(
          builder: (context, state) {
            if (state is AddonsLoading) {
              return const CustomLoading();
            }
            if (state is AddonsError || state is AddonsDeleteError) {
              final message = state is AddonsError
                  ? state.message
                  : (state as AddonsDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<AddonsCubit>().getAll(),
              );
            }
            final addons = context.read<AddonsCubit>().addons;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: 'add_addon',
                  onPressed: () async {
                    addonDetails(context);
                  },
                ),
                Expanded(
                  child: ListOfAddonsWidget(
                    addons: addons,
                    onEdit: (item) => addonDetails(context, addon: item),
                    onDelete: (item) {
                      context.read<AddonsCubit>().deleteById(item.id!);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
