import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/custom_failed_widget.dart';
import '../../../core/widgets/custom_loading.dart';
import '../../cart/orders/model/order_model.dart';
import '../cubit/shift_details_cubit.dart';

class ItemDetailsWidget extends StatefulWidget {
  const ItemDetailsWidget({
    super.key,
    required this.paymentMethodId,
    required this.orderType,
    required this.orderTypeName,
  });
  final int paymentMethodId;
  final int orderType;
  final String orderTypeName;

  @override
  State<ItemDetailsWidget> createState() => _ItemDetailsWidgetState();
}

class _ItemDetailsWidgetState extends State<ItemDetailsWidget> {
  ScreenState screenState = ScreenState.loading;
  List<OrderModel> orders = [];

  String? errorMessage;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getOrderData();
    });
  }

  getOrderData() async {
    final cubit = context.read<ShiftDetailsCubit>();
    setState(() {
      screenState = ScreenState.loading;
    });
    log(
      'selectedPriceList: ${cubit.selectedPriceList?.id} -  paymentMethodId: ${widget.paymentMethodId} - custodyId: ${cubit.custodyId}',
    );
    final result = await cubit.ordersRepo.getOrdersByFilters(
      custodyId: cubit.custodyId ?? 0,
      selectedPriceListId: cubit.selectedPriceList?.id ?? 0,
      orderType: widget.orderType,
      paymentMethodId: widget.paymentMethodId,
    );
    result.fold(
      (f) {
        log('error: $f');
        errorMessage = f.failureMessage ?? 'Error';
        setState(() {
          screenState = ScreenState.error;
        });
      },
      (orders) {
        log('orders: $orders');
        setState(() {
          this.orders = orders;

          screenState = ScreenState.loaded;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (screenState == ScreenState.loading) {
      return const CustomLoading();
    } else if (screenState == ScreenState.error) {
      return CustomFailedWidget(message: errorMessage ?? 'Error');
    }
    if (orders.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.orderTypeName.tr(),
          style: AppFonts.styleBold22.copyWith(fontFamily: AppFonts.enFamily),
        ),
        ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (context, index) => SizedBox(height: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, orderIndex) {
            final cubit = context.read<ShiftDetailsCubit>();
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text("#${orders[orderIndex].id.toString()}"),
                        ),
                        Text(
                          "${orders[orderIndex].total.toString()} ${cubit.selectedPriceList?.name ?? ''}",
                          style: AppFonts.styleMedium18.copyWith(
                            fontFamily: AppFonts.enFamily,
                          ),
                        ),
                      ],
                    ),
                    ListView.separated(
                      itemCount: orders[orderIndex].items?.length ?? 0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 10),
                      itemBuilder: (context, itemIndex) {
                        final item = orders[orderIndex].items?[itemIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item?.productName ?? '',
                              style: AppFonts.styleMedium18.copyWith(
                                fontFamily: AppFonts.enFamily,
                              ),
                            ),
                            Text(
                              item?.variantLabel ?? '',
                              style: AppFonts.styleMedium16.copyWith(
                                fontFamily: AppFonts.enFamily,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
