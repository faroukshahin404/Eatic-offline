import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_size.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/create_order_cubit.dart';
import 'components_widgets/create_order_addons_section.dart';

class AddonsAndNotesWidget extends StatelessWidget {
  const AddonsAndNotesWidget({super.key, required this.cubit});

  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (AppSize.isMobile()) {
      return Column(
        spacing: 16,
        children: [
          if (cubit.selectedVariant != null) ...[
            CreateOrderAddonsSection(cubit: cubit),
          ],
          CustomTextField(
            title: "${'create_order.notes'.tr()}:",
            maxLines: 4,

            hint: 'create_order.notes'.tr(),
            controller: cubit.notesController,
          ),
        ],
      );
    } else {
      return Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cubit.selectedVariant != null) ...[
            Expanded(child: CreateOrderAddonsSection(cubit: cubit)),
          ],
          Expanded(
            child: CustomTextField(
              title: "${'create_order.notes'.tr()}:",
              hint: 'create_order.notes'.tr(),
              maxLines: 4,
              controller: cubit.notesController,
            ),
          ),
        ],
      );
    }
  }
}
