import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/custom_text_field.dart';
import '../activation/models/activation_mode.dart';
import 'cubit/installation_cubit.dart';
import 'services/purchase_key_input_formatter.dart';

class InstallationScreen extends StatelessWidget {
  const InstallationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: SafeArea(
        child: BlocConsumer<InstallationCubit, InstallationState>(
          listener: (context, state) {
            if (state.nextPath != null) {
              context.go(state.nextPath!);
              return;
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            final cubit = context.read<InstallationCubit>();
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: CustomPadding(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.greyE6E9EA),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _HeaderSection(),
                          const SizedBox(height: 20),
                          _ModeSelector(
                            selectedMode: state.selectedMode,
                            onModeChanged: cubit.setMode,
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: cubit.formKey,
                            child: CustomTextField(
                              title: 'Purchase Key',
                              hint: 'xxxx-xxxx-xxxx-xxxx',
                              controller: cubit.purchaseKeyController,
                              keyboardType: TextInputType.number,
                              onChanged: cubit.onPurchaseKeyChanged,
                              prefix: const Padding(
                                padding: EdgeInsetsDirectional.only(start: 12),
                                child: Icon(Icons.key_rounded, size: 20),
                              ),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                PurchaseKeyInputFormatter(),
                              ],
                              validator: (value) {
                                final input = value?.trim() ?? '';
                                final isValid = RegExp(
                                  r'^\d{4}-\d{4}-\d{4}-\d{4}$',
                                ).hasMatch(input);
                                if (!isValid) {
                                  return 'Purchase key must match xxxx-xxxx-xxxx-xxxx';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Example: 1234-5678-9012-3456',
                            style: AppFonts.styleRegular12.copyWith(
                              color: AppColors.greyA4ACAD,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _ConnectionStatusFooter(
                            hasInternetConnection: state.hasInternetConnection,
                            isCheckingConnection: state.isCheckingConnection,
                            onRecheck: cubit.recheckInternetConnection,
                            onSubmit: state.canProceed ? cubit.activate : null,
                            isSubmitting: state.isSubmitting,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفعيل الجهاز',
                style: AppFonts.styleBold24.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'اختر وضع التشغيل ثم أدخل مفتاح الشراء لإتمام التفعيل.',
                style: AppFonts.styleRegular15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.selectedMode,
    required this.onModeChanged,
  });

  final ActivationMode? selectedMode;
  final ValueChanged<ActivationMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyE6E9EA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.devices_other_rounded, size: 18),
              const SizedBox(width: 8),
              Text('وضع التشغيل', style: AppFonts.styleSemiBold16),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  title: 'Online',
                  subtitle: 'التشغيل مع المزامنة',
                  icon: Icons.cloud_sync_rounded,
                  selected: selectedMode == ActivationMode.online,
                  onTap: () => onModeChanged(ActivationMode.online),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeCard(
                  title: 'Offline',
                  subtitle: 'التشغيل بدون مزامنة',
                  icon: Icons.cloud_off_rounded,
                  selected: selectedMode == ActivationMode.offline,
                  onTap: () => onModeChanged(ActivationMode.offline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return const Icon(
        Icons.radio_button_unchecked_rounded,
        size: 20,
        color: AppColors.greyA4ACAD,
      );
    }
    return const Icon(
      Icons.check_circle_rounded,
      size: 20,
      color: AppColors.primary,
    );
  }
}

class _ModeIconBadge extends StatelessWidget {
  const _ModeIconBadge({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.greyE6E9EA.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        icon,
        size: 20,
        color: selected ? AppColors.primary : AppColors.greyA4ACAD,
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.greyE6E9EA,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ModeIconBadge(icon: icon, selected: selected),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: AppFonts.styleSemiBold16)),
                _SelectionIndicator(selected: selected),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppFonts.styleRegular14.copyWith(
                color: AppColors.oppositeColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionStatusFooter extends StatelessWidget {
  const _ConnectionStatusFooter({
    required this.hasInternetConnection,
    required this.isCheckingConnection,
    required this.onRecheck,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final bool hasInternetConnection;
  final bool isCheckingConnection;
  final VoidCallback onRecheck;
  final VoidCallback? onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final statusColor = hasInternetConnection ? Colors.green : Colors.red;
    final statusText =
        hasInternetConnection
            ? 'Internet: Connected'
            : 'Internet: Not connected';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.greyE6E9EA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasInternetConnection
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Network Status', style: AppFonts.styleSemiBold14),
                    const SizedBox(height: 2),
                    Text(statusText, style: AppFonts.styleRegular14),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: isCheckingConnection ? null : onRecheck,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                icon:
                    isCheckingConnection
                        ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Re-check'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.greyA4ACAD,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Internet connection is required to activate this device.',
                  style: AppFonts.styleRegular12.copyWith(
                    color: AppColors.greyA4ACAD,
                  ),
                ),
              ),
              SizedBox(
                width: 170,
                child: CustomButtonWidget(
                  text: 'التالي',
                  onPressed: onSubmit,
                  isLoading: isSubmitting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
