import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/pos_crud_ui.dart';
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
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: CustomAppBar(title: "users"),
      body: CustomPadding(
        child: BlocBuilder<UsersCubit, UsersState>(
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
                SizedBox(
                  width: 220,
                  child: PosCrudActionButton(
                    label: 'add_user'.tr(),
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: () async {
                      await goToAddUser(context);
                    },
                  ),
                ),
                const SizedBox(height: 4),
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
