import 'package:flutter/material.dart';

import '../../cubit/create_order_cubit.dart';
import 'variants_column_layout.dart';
import 'variants_grid_layout.dart';

/// Section showing product variants: either column-based (one column per variable with radio options)
/// or legacy grid when variable groups are not available.
class CreateOrderVariantsSection extends StatelessWidget {
  const CreateOrderVariantsSection({super.key, required this.cubit});

  final CreateOrderCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit.variants.isEmpty) return const SizedBox.shrink();

    if (cubit.variableGroups.isNotEmpty) {
      return VariantsColumnLayout(cubit: cubit);
    }

    return VariantsGridLayout(cubit: cubit);
  }
}
