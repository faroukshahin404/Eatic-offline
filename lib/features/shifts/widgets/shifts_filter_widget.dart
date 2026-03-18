import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../cubit/shifts_cubit.dart';

class ShiftsFilterWidget extends StatefulWidget {
  const ShiftsFilterWidget({super.key});

  @override
  State<ShiftsFilterWidget> createState() => _ShiftsFilterWidgetState();
}

class _ShiftsFilterWidgetState extends State<ShiftsFilterWidget> {
  final _cashierCtrl = TextEditingController();

  @override
  void dispose() {
    _cashierCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _applyFilters() {
    context.read<ShiftsCubit>().search(cashierName: _cashierCtrl.text);
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final cubit = context.read<ShiftsCubit>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? cubit.from : cubit.to) ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (isFrom) {
        cubit.updateFromDate(picked);
      } else {
        cubit.updateToDate(picked);
      }
    });
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return DateFormat('d MMM yyyy', 'en').format(date);
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShiftsCubit>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _cashierCtrl,
              decoration: InputDecoration(
                labelText: 'shifts.cashier_name'.tr(),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _DatePickerField(
              label: 'shifts.from'.tr(),
              date: cubit.from,
              onTap: () => _pickDate(isFrom: true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _DatePickerField(
              label: 'shifts.to'.tr(),
              date: cubit.to,
              onTap: () => _pickDate(isFrom: false),
            ),
          ),
          const SizedBox(width: 12),
          CustomButtonWidget(text: 'shifts.search', onPressed: _applyFilters),
        ],
      ),
    );
  }
}

// ── Small private widget to reduce duplication ───────────────────────────────

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  static String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return DateFormat('d MMM yyyy', 'en').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        child: Text(
          _formatDate(date),
          style: TextStyle(
            color: date != null ? AppColors.primary : AppColors.greyA4ACAD,
          ),
        ),
      ),
    );
  }
}
