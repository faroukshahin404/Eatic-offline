import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../currencies/model/currency_model.dart';
import '../../currencies/repos/offline/currencies_offline_repos.dart';
import '../../price_lists/model/price_list_model.dart';
import '../repos/offline/add_new_price_list_offline_repos.dart';

part 'add_new_price_list_state.dart';

class AddNewPriceListCubit extends Cubit<AddNewPriceListState> {
  AddNewPriceListCubit(this._currenciesRepo, this._priceListRepo)
      : super(AddNewPriceListInitial());

  final CurrenciesOfflineRepository _currenciesRepo;
  final AddNewPriceListOfflineRepository _priceListRepo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  List<CurrencyModel> currencies = [];
  CurrencyModel? selectedCurrency;
  PriceListModel? priceList;

  @override
  Future<void> close() {
    nameController.dispose();
    return super.close();
  }

  void setPriceList(PriceListModel? value) {
    priceList = value;
    if (value != null) {
      nameController.text = value.name ?? '';
    } else {
      nameController.clear();
      selectedCurrency = null;
    }
  }

  Future<void> loadCurrencies() async {
    emit(AddNewPriceListLoadingCurrencies());
    final result = await _currenciesRepo.getAll();
    result.fold(
      (_) {
        currencies = [];
        emit(AddNewPriceListReady());
      },
      (list) {
        currencies = list;
        if (selectedCurrency == null && list.isNotEmpty) {
          selectedCurrency = list.first;
        }
        if (priceList != null && priceList!.currencyId != null) {
          for (final c in list) {
            if (c.id == priceList!.currencyId) {
              selectedCurrency = c;
              break;
            }
          }
        }
        emit(AddNewPriceListReady());
      },
    );
  }

  void selectCurrency(CurrencyModel? value) {
    selectedCurrency = value;
    emit(AddNewPriceListReady());
  }

  Future<void> savePriceList() async {
    if (formKey.currentState?.validate() != true) return;
    final name = nameController.text.trim();
    final currencyId = selectedCurrency?.id;
    if (currencyId == null) {
      emit(AddNewPriceListError('validation.required'.tr()));
      return;
    }

    if (priceList != null && priceList!.id != null) {
      final updated = priceList!.copyWith(
        name: name,
        currencyId: currencyId,
      );
      emit(AddNewPriceListSaving());
      final result = await _priceListRepo.update(updated);
      result.fold(
        (f) => emit(AddNewPriceListError(f.failureMessage ?? 'Error')),
        (_) => emit(
          AddNewPriceListSaved(id: priceList!.id, isUpdate: true),
        ),
      );
    } else {
      final newModel = PriceListModel(
        vendorId: null,
        currencyId: currencyId,
        name: name,
      );
      emit(AddNewPriceListSaving());
      final result = await _priceListRepo.insert(newModel);
      result.fold(
        (f) => emit(AddNewPriceListError(f.failureMessage ?? 'Error')),
        (id) => emit(AddNewPriceListSaved(id: id, isUpdate: false)),
      );
    }
  }
}
