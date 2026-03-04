
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../routes/app_paths.dart';
import 'cubit/users_cubit.dart';
import 'widgets/list_of_user_widget.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  Future<void> goToAddUser(BuildContext context, {int? id}) async {
    final result = await context.push<bool>(AppPaths.addUser, extra: id);
    if (result == true) {
      if (!(context.mounted)) return;
      context.read<UsersCubit>().getUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "users"),
      body: CustomPadding(
        child: BlocConsumer<UsersCubit, UsersState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is UsersLoading) {
              return const CustomLoading();
            }
            if (state is UsersError) {
              return CustomFailedWidget(
                message: state.message,
                onRetry: () => context.read<UsersCubit>().getUsers(),
              );
            }
            final users = context.read<UsersCubit>().users;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomButtonWidget(
                  text: "add_user",
                  onPressed: () async {
                    await goToAddUser(context);
                  },
                ),
                Expanded(
                  child: ListOfUserWidget(
                    users: users,
                    onEdit: (user) async {
                      await goToAddUser(context, id: user.id);
                    },
                    onDelete: (user) {
                      context.read<UsersCubit>().deleteUser(id: user.id);
                    },
                    onView: (user) async {
                      await goToAddUser(context, id: user.id);
                    },
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
