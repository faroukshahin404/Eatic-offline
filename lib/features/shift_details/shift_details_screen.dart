import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/shift_details_cubit.dart';

class ShiftDetailsScreen extends StatelessWidget {
  const ShiftDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'shift_details'),
      body: BlocConsumer<ShiftDetailsCubit, ShiftDetailsState>(
        listenWhen: (previous, current) => current is ShiftDetailsError,
        listener: (context, state) {
          if (state is ShiftDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShiftDetailsLoading) return const CustomLoading();

          if (state is ShiftDetailsLoaded || state is ShiftDetailsPrinting) {
            final receiptPreview =
                state is ShiftDetailsLoaded
                    ? state.receiptPreview
                    : (state as ShiftDetailsPrinting).receiptPreview;
            final isPrinting = state is ShiftDetailsPrinting;
            return CustomPadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        isPrinting
                            ? null
                            : () async {
                              final printed =
                                  await context
                                      .read<ShiftDetailsCubit>()
                                      .printCustodyReviewReceipt();
                              if (printed && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'shift_details_report.print_success'.tr(),
                                    ),
                                    backgroundColor: Colors.green.shade700,
                                  ),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'shift_details_report.print_failed'.tr(),
                                    ),
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                );
                              }
                            },
                    icon:
                        isPrinting
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.print_rounded),
                    label: Text('shift_details_report.print'.tr()),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.greyA4ACAD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          receiptPreview,
                          style: AppFonts.styleMedium16.copyWith(
                            fontFamily: 'monospace',
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ShiftDetailsError) {
            return CustomFailedWidget(message: state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
