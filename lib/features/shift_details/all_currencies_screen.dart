import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../routes/app_paths.dart';
import 'cubit/shift_details_cubit.dart';

class AllCurrenciesScreen extends StatelessWidget {
  const AllCurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'all_currencies'),
      body: BlocBuilder<ShiftDetailsCubit, ShiftDetailsState>(
        builder: (context, state) {
          if (state is ShiftDetailsLoading) {
            return const CustomLoading();
          } else if (state is ShiftDetailsError) {
            return CustomFailedWidget(
              message: state.message,
              onRetry: () => context.read<ShiftDetailsCubit>().getAll(),
            );
          }
          final priceLists = context.read<ShiftDetailsCubit>().priceLists;
          return CustomPadding(
            child: ListView.builder(
              itemCount: priceLists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(priceLists[index].name ?? ''),
                  trailing: IconButton(
                    onPressed: () {
                      context.read<ShiftDetailsCubit>().setSelectedPriceList(
                        priceLists[index],
                      );
                      final cubit = context.read<ShiftDetailsCubit>();
                      context.push(AppPaths.shiftDetails, extra: cubit);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
