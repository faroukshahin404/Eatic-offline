import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/services/platform_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/pos_crud_ui.dart';
import '../../services_locator/service_locator.dart';
import '../add_new_branch/add_new_branch_screen.dart';
import '../add_new_branch/cubit/add_new_branch_cubit.dart';
import '../add_new_branch/widgets/add_new_branch_form_widget.dart';
import 'cubit/branches_cubit.dart';
import 'model/branch_model.dart';
import 'widgets/branches_table_widget.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  bool _showInlineCreateForm = false;

  Future<void> _openBranchDetails(
    BuildContext context, {
    BranchModel? branch,
  }) async {
    final result = await PlatformSheet.show(
      context: context,
      isScrollControlled: false,
      child: AddNewBranchScreen(branch: branch),
    );
    if (result == true) {
      if (!(context.mounted)) return;
      context.read<BranchesCubit>().getBranches();
    }
  }

  void _toggleInlineCreateForm() {
    setState(() => _showInlineCreateForm = !_showInlineCreateForm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: "branches"),
      body: CustomPadding(
        child: BlocBuilder<BranchesCubit, BranchesState>(
          builder: (context, state) {
            if (state is BranchesLoading) {
              return const CustomLoading();
            }
            if (state is BranchesError) {
              return CustomFailedWidget(message: state.message);
            }
            final branches = context.read<BranchesCubit>().branches;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 220,
                      child: PosCrudActionButton(
                        label:
                            _showInlineCreateForm
                                ? 'dialog.cancel'.tr()
                                : 'add_branch'.tr(),
                        icon:
                            _showInlineCreateForm
                                ? Icons.close_rounded
                                : Icons.add_business_outlined,
                        isPrimary: !_showInlineCreateForm,
                        onPressed: _toggleInlineCreateForm,
                      ),
                    ),
                  ],
                ),
                if (_showInlineCreateForm)
                  BlocProvider<AddNewBranchCubit>(
                    create: (context) => getIt<AddNewBranchCubit>(),
                    child: BlocConsumer<AddNewBranchCubit, AddNewBranchState>(
                      listener: (context, formState) {
                        if (formState is AddNewBranchSaved) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("add_branch_form.success".tr()),
                            ),
                          );
                          setState(() => _showInlineCreateForm = false);
                          context.read<BranchesCubit>().getBranches();
                        }
                      },
                      builder: (context, formState) {
                        if (formState is AddNewBranchLoading) {
                          return const CustomLoading();
                        }
                        if (formState is AddNewBranchError) {
                          return CustomFailedWidget(message: formState.message);
                        }
                        return const AddNewBranchFormWidget();
                      },
                    ),
                  ),
                Expanded(
                  child: BranchesTableWidget(
                    branches: branches,
                    onEdit:
                        (branch) => _openBranchDetails(context, branch: branch),
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
