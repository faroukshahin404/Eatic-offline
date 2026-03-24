import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cart/orders/model/order_model.dart';
import '../../cart/orders/model/order_type_model.dart';
import '../../cart/orders/repos/offline/orders_offline_repos.dart';
import '../../currencies/model/currency_model.dart';
import '../../currencies/repos/offline/currencies_offline_repos.dart';
import '../../payment_methods/model/payment_method_model.dart';
import '../../payment_methods/repos/offline/payment_methods_offline_repos.dart';
import '../../price_lists/model/price_list_model.dart';
import '../../price_lists/repos/offline/price_lists_offline_repos.dart';

part 'shift_details_state.dart';

class ShiftDetailsCubit extends Cubit<ShiftDetailsState> {
  ShiftDetailsCubit(
    this.paymentMethodsOfflineRepository,
    this.ordersRepo,
    this.priceListsOfflineRepository,
  ) : super(ShiftDetailsInitial());

  final PaymentMethodsOfflineRepository paymentMethodsOfflineRepository;
  final OrdersOfflineRepository ordersRepo;
  final PriceListsOfflineRepository priceListsOfflineRepository;

  List<OrderTypeModel> orderTypes = [];

  List<PriceListModel> priceLists = [];
  List<PaymentMethodModel> paymentMethods = [];

  PriceListModel? selectedPriceList;

  int? custodyId;

  List<OrderModel> orders = [];

  Future<void> loadOrderTypes() async {
    final result = await ordersRepo.getOrderTypes();
    result.fold(
      (f) => emit(ShiftDetailsError(message: f.failureMessage ?? 'Error')),
      (list) {
        orderTypes = list;
        emit(ShiftDetailsLoaded());
      },
    );
  }

  Future<void> getAll({int? custodyId}) async {
    if (custodyId != null) {
      this.custodyId = custodyId;
    }
    emit(ShiftDetailsLoading());
    final result = await priceListsOfflineRepository.getAll();
    result.fold(
      (f) => emit(ShiftDetailsError(message: f.failureMessage ?? 'Error')),
      (list) {
        priceLists = list;
        selectedPriceList ??= priceLists.first;
        getAllPaymentMethods();
      },
    );
  }

  Future<void> getAllPaymentMethods() async {
    final result = await paymentMethodsOfflineRepository.getAll();
    result.fold(
      (f) => emit(ShiftDetailsError(message: f.failureMessage ?? 'Error')),
      (list) {
        log('paymentMethods: $list');
        paymentMethods = list;
        loadOrderTypes();
      },
    );
  }

  void setSelectedPriceList(PriceListModel priceList) {
    selectedPriceList = priceList;
    emit(ShiftDetailsLoaded());
  }
}
