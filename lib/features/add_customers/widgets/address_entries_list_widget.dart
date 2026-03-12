import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/add_customer_cubit.dart';
import 'address_form_block.dart';

class AddressEntriesListWidget extends StatelessWidget {
  const AddressEntriesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCustomerCubit, AddCustomerState>(
      buildWhen: (p, c) => c is AddCustomerReady || c is AddCustomerInitial,
      builder: (context, state) {
        final entries = context.read<AddCustomerCubit>().addressEntries;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (context, i) => AddressFormBlock(
            index: i,
            entry: entries[i],
            canRemove: entries.length > 1,
          ),
        );
      },
    );
  }
}
