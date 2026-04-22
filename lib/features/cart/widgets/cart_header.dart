import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_colors.dart';
import '../../custody/widgets/custody_confirm_close_dialog.dart';
import '../../custody/widgets/custody_confirm_open_dialog.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

/// Cart header: Add New Order and Close Custody buttons.
class CartHeader extends StatelessWidget {
  const CartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: BlocBuilder<CartCubit, CartState>(
        buildWhen: (p, c) => p.hasOpenCustody != c.hasOpenCustody,
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _HeaderIconAction(
                tooltip: 'cart.add_new_order'.tr(),
                icon: Icons.add_shopping_cart_rounded,
                onTap: () => context.read<CartCubit>().clearCart(),
              ),
              const SizedBox(width: 8),
              _HeaderIconAction(
                tooltip:
                    state.hasOpenCustody
                        ? 'custody.close_custody'.tr()
                        : 'custody.open_new'.tr(),
                icon:
                    state.hasOpenCustody
                        ? Icons.lock_outline_rounded
                        : Icons.lock_open_rounded,
                onTap: () {
                  final cartCubit = context.read<CartCubit>();
                  final dialogFuture =
                      state.hasOpenCustody
                          ? showCustodyConfirmCloseDialog(context)
                          : showCustodyConfirmOpenDialog(context);
                  dialogFuture.then((result) {
                    if (result == true) {
                      cartCubit.refreshHasOpenCustody();
                    }
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderIconAction extends StatelessWidget {
  const _HeaderIconAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.fillColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.greyE6E9EA),
          ),
          child: Icon(icon, size: 18, color: AppColors.oppositeColor),
        ),
      ),
    );
  }
}
