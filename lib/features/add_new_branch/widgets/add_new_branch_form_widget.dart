import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/add_new_branch_cubit.dart';

class AddNewBranchFormWidget extends StatelessWidget {
  const AddNewBranchFormWidget({super.key});

  static String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      final dt = DateTime.parse(value);
      return DateFormat('d MMMM yyyy - h:mm a', 'en').format(dt);
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddNewBranchCubit>();
    final branch = cubit.branch;
    return Form(
      key: cubit.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            title: 'add_branch_form.name'.tr(),
            hint: 'add_branch_form.name'.tr(),
            controller: cubit.nameController,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'validation.required'.tr()
                : null,
          ),
          if (branch != null) ...[
            const SizedBox(height: 20),
            _ReadOnlyField(
              label: 'add_branch_form.created_at'.tr(),
              value: '\u200E${_formatDate(branch.createdAt)}',
            ),
            const SizedBox(height: 12),
            _ReadOnlyField(
              label: 'add_branch_form.updated_at'.tr(),
              value: '\u200E${_formatDate(branch.updatedAt)}',
            ),
            const SizedBox(height: 12),
            _ReadOnlyField(
              label: 'add_branch_form.created_by'.tr(),
              value: branch.createdBy?.name ?? branch.createdBy?.code ?? '-',
            ),
          ],
          const SizedBox(height: 24),
          CustomButtonWidget(
            text: 'add_branch_form.save',
            onPressed: () => cubit.saveBranch(),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppFonts.styleBold16),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppFonts.styleBold16.copyWith(
            fontWeight: FontWeight.normal,
            fontFamily: AppFonts.enFamily,
          ),
        ),
      ],
    );
  }
}
