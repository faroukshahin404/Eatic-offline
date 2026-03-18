import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../custody/model/custody_model.dart';
import 'cubit/shifts_cubit.dart';
import 'cubit/shifts_state.dart';
import 'widgets/shifts_table_widget.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  final _cashierCtrl = TextEditingController();
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    context.read<ShiftsCubit>().loadAllShifts();
  }

  @override
  void dispose() {
    _cashierCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<ShiftsCubit>().search(
      cashierName: _cashierCtrl.text,
      from: _from,
      to: _to,
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to != null && _to!.isBefore(_from!)) _to = _from;
      } else {
        _to = picked;
        if (_from != null && _from!.isAfter(_to!)) _from = _to;
      }
    });
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return DateFormat('d MMM yyyy', 'en').format(date);
  }

  static String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat('d MMM yyyy, HH:mm', 'en')
          .format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  void _onShow(CustodyModel custody) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('shifts.details'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'table.id'.tr()}: ${custody.id}'),
            const SizedBox(height: 8),
            Text('${'table.name'.tr()}: ${custody.userModel?.name ?? '-'}'),
            const SizedBox(height: 8),
            Text('${'shifts.time'.tr()}: ${_formatTime(custody.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('dialog.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'shifts.title'),
      body: Column(
        children: [
          Padding(
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
                  child: InkWell(
                    onTap: () => _pickDate(isFrom: true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'shifts.from'.tr(),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        _formatDate(_from),
                        style: TextStyle(
                          color: _from != null
                              ? AppColors.primary
                              : AppColors.greyA4ACAD,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _pickDate(isFrom: false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'shifts.to'.tr(),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        _formatDate(_to),
                        style: TextStyle(
                          color: _to != null
                              ? AppColors.primary
                              : AppColors.greyA4ACAD,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CustomButtonWidget(
                  text: 'shifts.search',
                  onPressed: _applyFilters,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ShiftsCubit, ShiftsState>(
              builder: (context, state) {
                if (state is ShiftsLoading) return const CustomLoading();
                if (state is ShiftsError) {
                  return CustomFailedWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<ShiftsCubit>().loadAllShifts(),
                  );
                }
                if (state is ShiftsLoaded) {
                  return ShiftsTableWidget(
                    custodies: state.custodies,
                    onShow: _onShow,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
