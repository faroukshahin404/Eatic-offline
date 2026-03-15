
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/custom_button_widget.dart';
import '../../custody/widgets/custody_confirm_close_dialog.dart';
import '../../custody/widgets/custody_confirm_open_dialog.dart';
import '../cubit/cart_cubit.dart';

/// Outlined-style button: opens or closes custody based on [hasOpenCustody].
class CartCloseCustodyButton extends StatefulWidget {
  const CartCloseCustodyButton({super.key});

  @override
  State<CartCloseCustodyButton> createState() => _CartCloseCustodyButtonState();
}

class _CartCloseCustodyButtonState extends State<CartCloseCustodyButton> {
  bool hasOpenCustody = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getLastCustody();
    });
  }

  Future<void> getLastCustody() async {
    final getLastOpenCustody =
        await AppUtils.navigatorKey.currentContext!
            .read<CartCubit>()
            .custodyRepo
            .getLastOpenCustody();

    getLastOpenCustody.fold(
      (_) {
        hasOpenCustody = false;
      },
      (v) {
        hasOpenCustody = (v?.isClosed == false);
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomButtonWidget(
      text:
          hasOpenCustody
              ? 'custody.close_custody'.tr()
              : 'custody.open_new'.tr(),
      onPressed: () => _onPressed(context),
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    if (hasOpenCustody) {
      final result = await showCustodyConfirmCloseDialog(context);
      if (context.mounted && result == true) {
        await getLastCustody();
      }
    } else {
      final result = await showCustodyConfirmOpenDialog(context);
      if (context.mounted && result == true) {
        await getLastCustody();
      }
    }
  }
}
