import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/platform_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../add_new_dining_area/add_new_dining_area_screen.dart';
import 'cubit/dining_areas_cubit.dart';
import 'model/dining_area_model.dart';
import 'widgets/list_of_dining_areas_widget.dart';

class DiningAreasScreen extends StatelessWidget {
  const DiningAreasScreen({super.key});

  static Future<void> diningAreaDetails(
    BuildContext context, {
    DiningAreaModel? diningArea,
  }) async {
    final result = await PlatformSheet.show(
      context: context,
      isScrollControlled: false,
      child: AddNewDiningAreaScreen(diningArea: diningArea),
    );
    if (result == true) {
      if (!(context.mounted)) return;
      context.read<DiningAreasCubit>().getAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'dining_areas'),
      body: CustomPadding(
        child: BlocBuilder<DiningAreasCubit, DiningAreasState>(
          builder: (context, state) {
            if (state is DiningAreasLoading) {
              return const CustomLoading();
            }
            if (state is DiningAreasError ||
                state is DiningAreasDeleteError) {
              final message = state is DiningAreasError
                  ? state.message
                  : (state as DiningAreasDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<DiningAreasCubit>().getAll(),
              );
            }
            final diningAreas =
                context.read<DiningAreasCubit>().diningAreas;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: 'add_dining_area',
                  onPressed: () async {
                    diningAreaDetails(context);
                  },
                ),
                Expanded(
                  child: ListOfDiningAreasWidget(
                    diningAreas: diningAreas,
                    onEdit: (item) =>
                        diningAreaDetails(context, diningArea: item),
                    onDelete: (item) {
                      context
                          .read<DiningAreasCubit>()
                          .deleteById(item.id!);
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
