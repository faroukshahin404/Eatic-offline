import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../addons/model/addon_model.dart';
import '../../categories/model/category_model.dart';
import '../../categories/repos/offline/categories_offline_repos.dart';
import '../../addons/repos/offline/addons_offline_repos.dart';
import '../../price_lists/model/price_list_model.dart';
import '../../price_lists/repos/offline/price_lists_offline_repos.dart';
import '../model/add_product_input.dart';
import '../model/product_detail_model.dart';
import '../model/product_variable_row.dart';
import '../model/variant_prices_row.dart';
import '../repos/offline/add_new_product_offline_repos.dart';

part 'add_new_product_state.dart';

/// Cartesian product of lists of strings (labels). First list varies slowest.
List<List<String>> _cartesianLabels(List<List<String>> lists) {
  if (lists.isEmpty) return [];
  if (lists.length == 1) return lists.first.map((e) => [e]).toList();
  final rest = _cartesianLabels(lists.sublist(1));
  final result = <List<String>>[];
  for (final head in lists.first) {
    for (final tail in rest) {
      result.add([head, ...tail]);
    }
  }
  return result;
}

class AddNewProductCubit extends Cubit<AddNewProductState> {
  AddNewProductCubit(
    this._categoriesRepo,
    this._addonsRepo,
    this._priceListsRepo,
    this._productRepo,
  ) : super(AddNewProductInitial());

  final CategoriesOfflineRepository _categoriesRepo;
  final AddonsOfflineRepository _addonsRepo;
  final PriceListsOfflineRepository _priceListsRepo;
  final AddNewProductOfflineRepository _productRepo;

  /// Set when editing an existing product (from getProductById).
  int? get productId => _productId;
  int? _productId;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameEnController = TextEditingController();
  final descriptionController = TextEditingController();

  List<CategoryModel> categories = [];
  List<AddonModel> addons = [];
  List<PriceListModel> priceLists = [];

  final Set<int> selectedCategoryIds = {};
  final Set<int> selectedAddonIds = {};
  bool hasVariants = false;
  final List<ProductVariableRow> variableRows = [];

  /// Variant rows for the table (labels + prices). Order = cartesian product.
  List<({String label, VariantPricesRow prices})> get variantTableRows {
    final valueLists = variableRows
        .map((r) => r.values.where((v) => v.trim().isNotEmpty).toList())
        .where((l) => l.isNotEmpty)
        .toList();
    if (valueLists.isEmpty) return [];
    final combinations = _cartesianLabels(valueLists);
    final labels = combinations.map((c) => c.join(' - ')).toList();
    final rows = <({String label, VariantPricesRow prices})>[];
    for (var i = 0; i < labels.length; i++) {
      final existing = _variantPricesRows.length > i
          ? _variantPricesRows[i]
          : null;
      rows.add((label: labels[i], prices: existing ?? VariantPricesRow()));
    }
    return rows;
  }

  /// Backing storage for variant prices (same order as cartesian product).
  final List<VariantPricesRow> _variantPricesRows = [];

  List<VariantPricesRow> get variantPricesRows {
    final valueLists = variableRows
        .map((r) => r.values.where((v) => v.trim().isNotEmpty).toList())
        .where((l) => l.isNotEmpty)
        .toList();
    if (valueLists.isEmpty) return [];
    final n = valueLists.fold<int>(1, (a, b) => a * b.length);
    while (_variantPricesRows.length < n) {
      _variantPricesRows.add(VariantPricesRow());
    }
    if (_variantPricesRows.length > n) {
      _variantPricesRows.removeRange(n, _variantPricesRows.length);
    }
    return _variantPricesRows;
  }

  /// Product-level price list prices (when no variants).
  final Map<int, double> productPriceListPrices = {};

  Future<void> loadData({int? productId}) async {
    emit(AddNewProductLoading());
    _productId = productId;

    final catResult = await _categoriesRepo.getAll();
    final addonResult = await _addonsRepo.getAll();
    final priceResult = await _priceListsRepo.getAll();
    catResult.fold((_) => categories = [], (l) => categories = l);
    addonResult.fold((_) => addons = [], (l) => addons = l);
    priceResult.fold((_) => priceLists = [], (l) => priceLists = l);

    if (productId != null) {
      final productResult = await _productRepo.getProductById(productId);
      await productResult.fold(
        (f) async => emit(AddNewProductError(f.failureMessage ?? 'Error')),
        (detail) async {
          _applyProductDetailToForm(detail);

          Future.delayed(const Duration(seconds: 1), () {
            emit(AddNewProductReady());
          });
        },
      );
      return;
    }

    emit(AddNewProductReady());
  }

  /// Fills form state and controllers from a loaded ProductDetailModel.
  void _applyProductDetailToForm(ProductDetailModel detail) {
    nameController.text = detail.name;
    nameEnController.text = detail.nameEn ?? '';
    descriptionController.text = detail.description ?? '';

    selectedCategoryIds.clear();
    selectedCategoryIds.addAll(detail.categoryIds);

    selectedAddonIds.clear();
    selectedAddonIds.addAll(detail.addonIds);

    hasVariants = detail.hasVariants;
    variableRows.clear();
    for (final row in detail.variableRows) {
      variableRows.add(
        ProductVariableRow(
          id: row.id,
          name: row.name,
          values: List.from(row.values),
        ),
      );
    }

    productPriceListPrices.clear();
    productPriceListPrices.addAll(detail.productPriceListPrices);

    _variantPricesRows.clear();
    for (final r in detail.variantPricesRows) {
      _variantPricesRows.add(
        VariantPricesRow(
          basePrice: r.basePrice,
          isActive: r.isActive,
          priceListPrices: Map.from(r.priceListPrices),
          addonPrices: Map.from(r.addonPrices),
        ),
      );
    }
  }

  void toggleCategory(int id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
    emit(AddNewProductReady());
  }

  void toggleAddon(int id) {
    if (selectedAddonIds.contains(id)) {
      selectedAddonIds.remove(id);
    } else {
      selectedAddonIds.add(id);
    }
    emit(AddNewProductReady());
  }

  void setHasVariants(bool value) {
    emit(AddNewProductInitial());
    log('setHasVariants: $value');
    hasVariants = value;
    if (!value) {
      variableRows.clear();
      _variantPricesRows.clear();
    }
    emit(AddNewProductReady());
  }

  void addVariableRow() {
    variableRows.add(ProductVariableRow());
    emit(AddNewProductReady());
  }

  void removeVariableRow(int index) {
    if (index >= 0 && index < variableRows.length) {
      variableRows.removeAt(index);
      _variantPricesRows.clear();
    }
    emit(AddNewProductReady());
  }

  void setVariableName(int rowIndex, String name) {
    if (rowIndex >= 0 && rowIndex < variableRows.length) {
      variableRows[rowIndex].name = name;
      emit(AddNewProductReady());
    }
  }

  void setVariableValue(int rowIndex, int valueIndex, String value) {
    if (rowIndex >= 0 && rowIndex < variableRows.length) {
      final row = variableRows[rowIndex].values;
      while (row.length <= valueIndex) row.add('');
      row[valueIndex] = value;
      emit(AddNewProductReady());
    }
  }

  void addVariableValue(int rowIndex) {
    if (rowIndex >= 0 && rowIndex < variableRows.length) {
      variableRows[rowIndex].values.add('');
      emit(AddNewProductReady());
    }
  }

  void removeVariableValue(int rowIndex, int valueIndex) {
    if (rowIndex >= 0 && rowIndex < variableRows.length) {
      final row = variableRows[rowIndex].values;
      if (valueIndex >= 0 && valueIndex < row.length) {
        row.removeAt(valueIndex);
        if (row.isEmpty) row.add('');
        emit(AddNewProductReady());
      }
    }
  }

  void setVariantBasePrice(int variantIndex, double value) {
    final rows = variantPricesRows;
    if (variantIndex >= 0 && variantIndex < rows.length) {
      rows[variantIndex].basePrice = value;
      emit(AddNewProductReady());
    }
  }

  void setVariantActive(int variantIndex, bool value) {
    final rows = variantPricesRows;
    if (variantIndex >= 0 && variantIndex < rows.length) {
      rows[variantIndex].isActive = value;
      emit(AddNewProductReady());
    }
  }

  void setVariantPriceListPrice(
    int variantIndex,
    int priceListId,
    double value,
  ) {
    final rows = variantPricesRows;
    if (variantIndex >= 0 && variantIndex < rows.length) {
      rows[variantIndex].priceListPrices[priceListId] = value;
      emit(AddNewProductReady());
    }
  }

  void setVariantAddonPrice(int variantIndex, int addonId, double value) {
    final rows = variantPricesRows;
    if (variantIndex >= 0 && variantIndex < rows.length) {
      rows[variantIndex].addonPrices[addonId] = value;
      emit(AddNewProductReady());
    }
  }

  void setProductPriceListPrice(int priceListId, double value) {
    productPriceListPrices[priceListId] = value;
    emit(AddNewProductReady());
  }

  Future<void> saveProduct() async {
    if (formKey.currentState?.validate() != true) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final nameEn = nameEnController.text.trim().isEmpty
        ? null
        : nameEnController.text.trim();
    final description = descriptionController.text.trim().isEmpty
        ? null
        : descriptionController.text.trim();
    final categoryIds = selectedCategoryIds.toList();
    final addonIds = selectedAddonIds.toList();
    final variableRowsCopy = List<ProductVariableRow>.from(variableRows);
    final productPriceListPricesCopy = Map<int, double>.from(
      productPriceListPrices,
    );
    final variantPricesRowsCopy = hasVariants
        ? List<VariantPricesRow>.from(variantPricesRows)
        : <VariantPricesRow>[];

    emit(AddNewProductLoading());

    if (_productId != null) {
      final detail = ProductDetailModel(
        id: _productId!,
        name: name,
        nameEn: nameEn,
        description: description,
        categoryIds: categoryIds,
        hasVariants: hasVariants,
        variableRows: variableRowsCopy,
        addonIds: addonIds,
        productPriceListPrices: productPriceListPricesCopy,
        variantPricesRows: variantPricesRowsCopy,
      );
      final result = await _productRepo.updateProduct(detail);
      result.fold(
        (f) => emit(AddNewProductError(f.failureMessage ?? 'Error')),
        (_) => emit(AddNewProductSaved(_productId!)),
      );
    } else {
      final input = AddProductInput(
        name: name,
        nameEn: nameEn,
        description: description,
        categoryIds: categoryIds,
        hasVariants: hasVariants,
        variableRows: variableRowsCopy,
        addonIds: addonIds,
        productPriceListPrices: productPriceListPricesCopy,
        variantPricesRows: variantPricesRowsCopy,
      );
      final result = await _productRepo.insertProduct(input);
      result.fold(
        (f) => emit(AddNewProductError(f.failureMessage ?? 'Error')),
        (id) => emit(AddNewProductSaved(id)),
      );
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    nameEnController.dispose();
    descriptionController.dispose();
    return super.close();
  }
}
