import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../routes/app_paths.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/zones_cubit.dart';
import 'widgets/list_of_zones_widget.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'zones'),
      body: CustomPadding(
        child: BlocBuilder<ZonesCubit, ZonesState>(
          builder: (context, state) {
            if (state is ZonesLoading) {
              return const CustomLoading();
            }
            if (state is ZonesError || state is ZonesDeleteError) {
              final message = state is ZonesError
                  ? state.message
                  : (state as ZonesDeleteError).message;
              return CustomFailedWidget(
                message: message,
                onRetry: () => context.read<ZonesCubit>().getAllZones(),
              );
            }
            final zones = context.read<ZonesCubit>().zones;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: 'add_zone',
                  onPressed: () async {
                    final result =
                        await context.push<bool>(AppPaths.addZone);
                    if (result == true && context.mounted) {
                      context.read<ZonesCubit>().getAllZones();
                    }
                  },
                ),
                Expanded(
                  child: ListOfZonesWidget(
                    zones: zones,
                    onEdit: (item) async {
                      final result = await context.push<bool>(
                        AppPaths.addZone,
                        extra: item.id,
                      );
                      if (result == true && context.mounted) {
                        context.read<ZonesCubit>().getAllZones();
                      }
                    },
                    onDelete: (item) {
                      context.read<ZonesCubit>().deleteById(item.id!);
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
