import 'package:flutter/material.dart';

import '../cubit/create_order_cubit.dart';
import 'components_widgets/create_order_variants_section.dart';
import 'components_widgets/order_product_card.dart';
import 'components_widgets/price_list_dropdown.dart';
import 'addons_and_notes_widget.dart';

class CreateOrderBodyWidget extends StatelessWidget {
  const CreateOrderBodyWidget({super.key, required this.cubit});

  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderProductCard(),
          const SizedBox(height: 16),
          PriceListDropdown(cubit: cubit),

          const SizedBox(height: 16),
          CreateOrderVariantsSection(cubit: cubit),
          const SizedBox(height: 16),

          AddonsAndNotesWidget(cubit: cubit),
        ],
      ),
    );
  }
}
