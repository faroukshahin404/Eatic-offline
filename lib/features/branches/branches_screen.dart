import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/platform_bottom_sheet.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../add_new_branch/add_new_branch_screen.dart';
import 'cubit/branches_cubit.dart';
import 'model/branch_model.dart';
import 'widgets/branches_table_widget.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  static Future<void> branchDetails(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                CustomButtonWidget(
                  text: "add_branch",
                  onPressed: () async {
                    branchDetails(context);
                  },
                ),
                Expanded(
                  child: BranchesTableWidget(
                    branches: branches,
                    onEdit: (branch) => branchDetails(context, branch: branch),
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
