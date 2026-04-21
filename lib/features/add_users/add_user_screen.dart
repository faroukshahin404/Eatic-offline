import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import 'cubit/add_user_cubit.dart';
import 'widgets/list_of_form_user_widget.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key, this.userId});

  final int? userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: "add_user"),
      body: CustomPadding(
        child: BlocConsumer<AddUserCubit, AddUserState>(
          listener: (context, state) {
            if (state is AddUserSaved) {
              context.pop<bool>(true);
            }
          },
          builder: (context, state) {
            if (state is AddUserInitial || state is AddUserLoading) {
              return const CustomLoading();
            } else if (state is AddUserError) {
              return CustomFailedWidget(message: state.message);
            }
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyE6E9EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListFormUserWidget(userId: userId),
            );
          },
        ),
      ),
    );
  }
}
