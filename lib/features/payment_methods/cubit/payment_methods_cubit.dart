import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/payment_method_model.dart';
import '../repos/offline/payment_methods_offline_repos.dart';

part 'payment_methods_state.dart';

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  PaymentMethodsCubit(this._repository) : super(PaymentMethodsInitial());

  final PaymentMethodsOfflineRepository _repository;

  List<PaymentMethodModel> paymentMethods = [];

  Future<void> getAll() async {
    emit(PaymentMethodsLoading());
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(PaymentMethodsError(message: f.failureMessage ?? 'Error')),
      (list) {
        paymentMethods = list;
        emit(PaymentMethodsLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(PaymentMethodsLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) =>
          emit(PaymentMethodsDeleteError(message: f.failureMessage ?? 'Error')),
      (_) => getAll(),
    );
  }
}
