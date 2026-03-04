import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../currencies/model/currency_model.dart';
import '../repos/offline/add_new_currency_offline_repos.dart';

part 'add_new_currency_state.dart';

class AddNewCurrencyCubit extends Cubit<AddNewCurrencyState> {
  AddNewCurrencyCubit(this._repo) : super(AddNewCurrencyInitial());

  final AddNewCurrencyOfflineRepository _repo;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final symbolController = TextEditingController();

  CurrencyModel? existingCurrency;
  int? _currencyIdForEdit;

  @override
  Future<void> close() {
    nameController.dispose();
    codeController.dispose();
    symbolController.dispose();
    return super.close();
  }

  void setCurrencyIdForEdit(int id) {
    _currencyIdForEdit = id;
  }

  /// Loads form: if editing, fetches currency by id and prefills form.
  Future<void> load() async {
    emit(AddNewCurrencyLoading());
    if (_currencyIdForEdit != null) {
      final result = await _repo.getCurrencyById(_currencyIdForEdit!);
      result.fold(
        (f) => emit(AddNewCurrencyError(f.failureMessage ?? 'Error')),
        (currency) {
          if (currency != null) setExistingCurrency(currency);
          _currencyIdForEdit = null;
          emit(AddNewCurrencyFormLoaded());
        },
      );
    } else {
      emit(AddNewCurrencyFormLoaded());
    }
  }

  void setExistingCurrency(CurrencyModel? currency) {
    existingCurrency = currency;
    if (currency != null) {
      nameController.text = currency.name ?? '';
      codeController.text = currency.code ?? '';
      symbolController.text = currency.symbol ?? '';
    }
  }

  Future<void> saveCurrency() async {
    if (formKey.currentState?.validate() != true) return;
    final model = CurrencyModel(
      id: existingCurrency?.id,
      vendorId: existingCurrency?.vendorId,
      name: nameController.text.trim(),
      code: codeController.text.trim(),
      symbol: symbolController.text.trim().isEmpty
          ? null
          : symbolController.text.trim(),
      createdAt: existingCurrency?.createdAt,
      updatedAt: existingCurrency?.updatedAt,
    );
    emit(AddNewCurrencyLoading());
    final isUpdate = existingCurrency?.id != null;
    final result =
        isUpdate ? await _repo.update(model) : await _repo.insert(model);
    result.fold(
      (f) => emit(AddNewCurrencyError(f.failureMessage ?? 'Error')),
      (id) => emit(AddNewCurrencySaved(
        existingCurrency?.id ?? id,
        isUpdate: isUpdate,
      )),
    );
  }
}
