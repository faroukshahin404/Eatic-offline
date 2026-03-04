import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/delivery_model.dart';
import '../repos/offline/deliveries_offline_repos.dart';

part 'delivery_men_state.dart';

class DeliveryMenCubit extends Cubit<DeliveryMenState> {
  DeliveryMenCubit(this._repository) : super(DeliveryMenInitial());

  final DeliveriesOfflineRepository _repository;

  List<DeliveryModel> deliveryMen = [];

  Future<void> getAll() async {
    emit(DeliveryMenLoading());
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(DeliveryMenError(message: f.failureMessage ?? 'Error')),
      (list) {
        deliveryMen = list;
        emit(DeliveryMenLoaded());
      },
    );
  }

  Future<void> deleteById(int id) async {
    emit(DeliveryMenLoading());
    final result = await _repository.deleteById(id);
    result.fold(
      (f) => emit(DeliveryMenDeleteError(message: f.failureMessage ?? 'Error')),
      (_) => getAll(),
    );
  }
}
