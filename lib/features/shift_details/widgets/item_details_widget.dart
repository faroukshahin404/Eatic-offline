import 'package:flutter/material.dart';

/// Legacy placeholder kept for compatibility with older layouts.
class ItemDetailsWidget extends StatelessWidget {
  const ItemDetailsWidget({
    super.key,
    this.paymentMethodId = 0,
    this.orderType = 0,
    this.orderTypeName = '',
  });

  final int paymentMethodId;
  final int orderType;
  final String orderTypeName;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
