import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../services_locator/service_locator.dart';
import '../branches/model/branch_model.dart';
import 'cubit/add_new_branch_cubit.dart';
import 'widgets/add_new_branch_form_widget.dart';

class AddNewBranchScreen extends StatelessWidget {
  const AddNewBranchScreen({super.key, this.branch});
  final BranchModel? branch;

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      child: BlocProvider<AddNewBranchCubit>(
        create: (context) => getIt<AddNewBranchCubit>()..setBranch(branch),
        child: BlocConsumer<AddNewBranchCubit, AddNewBranchState>(
          listener: (context, state) {
            if (state is AddNewBranchSaved) {
              final messenger = ScaffoldMessenger.of(context);
              context.pop<bool>(true);
              messenger.showSnackBar(
                SnackBar(content: Text("add_branch_form.success".tr())),
              );
            }
          },
          builder: (context, state) {
            if (state is AddNewBranchLoading) {
              return const CustomLoading();
            } else if (state is AddNewBranchError) {
              return CustomFailedWidget(message: state.message);
            }
            return const AddNewBranchFormWidget();
          },
        ),
      ),
    );
  }
}
