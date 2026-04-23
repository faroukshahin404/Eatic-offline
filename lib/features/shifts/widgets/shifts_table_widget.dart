import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../custody/model/custody_model.dart';

class ShiftsTableWidget extends StatefulWidget {
  const ShiftsTableWidget({
    super.key,
    required this.custodies,
    required this.onShow,
  });

  final List<CustodyModel> custodies;
  final void Function(CustodyModel custody) onShow;

  @override
  State<ShiftsTableWidget> createState() => _ShiftsTableWidgetState();
}

class _ShiftsTableWidgetState extends State<ShiftsTableWidget> {
  final _vCtrl = ScrollController();
  final _hCtrl = ScrollController();

  @override
  void dispose() {
    _vCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  static String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat(
        'd MMM yyyy, HH:mm',
        'en',
      ).format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  static String _formatShiftDurationHours(CustodyModel custody) {
    final shiftStartedAt = custody.shiftStartedAt ?? custody.createdAt;
    final shiftEndedAt = custody.shiftEndedAt;
    if (shiftStartedAt == null || shiftEndedAt == null) return '-';
    try {
      final start = DateTime.parse(shiftStartedAt);
      final end = DateTime.parse(shiftEndedAt);
      if (end.isBefore(start)) return '-';
      final duration = end.difference(start);
      final hours = duration.inMinutes / 60;
      return '${hours.toStringAsFixed(2)} h';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.custodies.isEmpty) {
      return Center(
        child: Text(
          'shifts.no_records'.tr(),
          style: const TextStyle(color: AppColors.greyA4ACAD, fontSize: 16),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _vCtrl,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _vCtrl,
            child: Scrollbar(
              controller: _hCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _hCtrl,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.secondary,
                    ),
                    columns: [
                      DataColumn(label: Text('table.id'.tr())),
                      DataColumn(label: Text('table.name'.tr())),
                      DataColumn(label: Text('shifts.started_at'.tr())),
                      DataColumn(label: Text('shifts.ended_at'.tr())),
                      DataColumn(label: Text('shifts.total_hours'.tr())),
                      DataColumn(label: Text('table.actions'.tr())),
                    ],
                    rows: [
                      for (var i = 0; i < widget.custodies.length; i++)
                        DataRow(
                          color: WidgetStateProperty.all(
                            i.isEven ? Colors.white : AppColors.fillColor,
                          ),
                          cells: [
                            DataCell(Text('${widget.custodies[i].id}')),
                            DataCell(
                              Text(widget.custodies[i].userModel?.name ?? '-'),
                            ),
                            DataCell(
                              Text(
                                _formatTime(
                                  widget.custodies[i].shiftStartedAt ??
                                      widget.custodies[i].createdAt,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _formatTime(widget.custodies[i].shiftEndedAt),
                              ),
                            ),
                            DataCell(
                              Text(
                                _formatShiftDurationHours(widget.custodies[i]),
                              ),
                            ),
                            DataCell(
                              TextButton(
                                onPressed:
                                    () => widget.onShow(widget.custodies[i]),
                                child: Text('shifts.show'.tr()),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
