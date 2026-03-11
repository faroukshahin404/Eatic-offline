import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../add_new_product/model/product_model.dart';
import '../../price_lists/model/price_list_model.dart';
import '../../price_lists/repos/offline/price_lists_offline_repos.dart';
import '../model/create_order_addon_model.dart';
import '../model/create_order_variant_model.dart';
import '../repos/offline/create_order_offline_repos.dart';
import 'create_order_state.dart';

class CreateOrderCubit extends Cubit<CreateOrderState> {
  CreateOrderCubit(this._repo, this._priceListsRepo)
    : super(CreateOrderInitial());

  final CreateOrderOfflineRepository _repo;
  final PriceListsOfflineRepository _priceListsRepo;

  String? errorMessage;
  ProductModel? product;
  List<CreateOrderVariantModel> variants = [];
  List<CreateOrderVariableGroup> variableGroups = [];
  List<CreateOrderAddonModel> addons = [];
  List<PriceListModel> priceLists = [];
  int? selectedPriceListId;
  CreateOrderVariantModel? selectedVariant;

  /// Per-variable selection (variableId -> valueId). Used when [variableGroups] is non-empty.
  final Map<int, int> selectedValueIds = {};

  /// Addon id -> quantity (0 = not selected). Used for add-to-order addons with quantity.
  final Map<int, int> addonQuantities = {};

  /// Price lists with non-null id, for dropdown items.
  List<PriceListModel> get validPriceLists =>
      priceLists.where((pl) => pl.id != null).toList();

  /// Currently selected price list model, or null.
  PriceListModel? get selectedPriceList {
    for (final pl in validPriceLists) {
      if (pl.id == selectedPriceListId) return pl;
    }
    return null;
  }

  /// Display label for a price list in the dropdown.
  String priceListLabel(PriceListModel pl) => pl.name?.isNotEmpty == true
      ? pl.name!
      : 'create_order.price_list_id'.tr(namedArgs: {'id': '${pl.id}'});

  /// Loads product by id; if found, loads its variants and addons and emits [CreateOrderProductLoaded].
  Future<void> loadProductById(int productId) async {
    log('product: ${product.toString()}');
    if (product != null) return;
    emit(CreateOrderLoading());
    _clearProductData();

    final productVal = await _loadProduct(productId);
    if (productVal == null) return;

    final variantsList = await _loadVariants(productId);
    if (variantsList == null) return;

    final groupsResult = await _repo.getProductVariableGroups(productId);
    variableGroups = groupsResult.fold(
      (_) => <CreateOrderVariableGroup>[],
      (list) => list,
    );

    final addonsList = await _loadAddons(productId);
    if (addonsList == null) return;

    final priceListsResult = await _priceListsRepo.getAll();
    priceLists = priceListsResult.fold(
      (_) => <PriceListModel>[],
      (list) => list,
    );
    if (selectedPriceListId == null &&
        priceLists.isNotEmpty &&
        priceLists.first.id != null) {
      selectedPriceListId = priceLists.first.id;
    }

    product = productVal;
    variants = variantsList;
    addons = addonsList;
    emit(CreateOrderProductLoaded());
  }

  /// Updates selected price list and notifies listeners so dropdown rebuilds.
  void setSelectedPriceListId(int? id) {
    selectedPriceListId = id;
    if (state is CreateOrderProductLoaded) {
      emit(CreateOrderProductLoaded());
    }
  }

  /// Selects or clears the selected variant. Notifies listeners so grid rebuilds.
  /// Use this when using the legacy grid UI (no variable groups).
  void setSelectedVariant(CreateOrderVariantModel? variant) {
    selectedVariant = variant;
    if (state is CreateOrderProductLoaded) {
      emit(CreateOrderProductLoaded());
    }
  }

  /// Selects an option for a variable (column-based UI). Resolves [selectedVariant] when
  /// all variables have a selection. Persists selection for the next step.
  void setSelectedVariableValue(int variableId, int valueId) {
    selectedValueIds[variableId] = valueId;
    selectedVariant = _resolveVariantFromSelection();
    if (state is CreateOrderProductLoaded) {
      emit(CreateOrderProductLoaded());
    }
  }

  /// True when the given variable option is selected (for radio state).
  bool isVariableValueSelected(int variableId, int valueId) {
    return selectedValueIds[variableId] == valueId;
  }

  /// Resolves selected variant from [selectedValueIds] by matching variant [valueIds] in variable order.
  CreateOrderVariantModel? _resolveVariantFromSelection() {
    if (variableGroups.isEmpty ||
        selectedValueIds.length != variableGroups.length) {
      return null;
    }
    final orderedValueIds = <int>[];
    for (final g in variableGroups) {
      final valueId = selectedValueIds[g.variableId];
      if (valueId == null) return null;
      orderedValueIds.add(valueId);
    }
    for (final v in variants) {
      if (v.valueIds.length != orderedValueIds.length) continue;
      var match = true;
      for (var i = 0; i < orderedValueIds.length; i++) {
        if (v.valueIds[i] != orderedValueIds[i]) {
          match = false;
          break;
        }
      }
      if (match && v.isActive) return v;
    }
    return null;
  }

  /// Quantity of this addon in the order (0 if not selected).
  int getAddonQuantity(int addonId) => addonQuantities[addonId] ?? 0;

  /// Whether this addon is added to the meal (quantity > 0).
  bool isAddonSelected(int addonId) => getAddonQuantity(addonId) > 0;

  /// Selected variant price for the current price list (or base price if no price list / not in map).
  double? get selectedVariantPrice {
    if (selectedVariant == null) return null;
    final v = selectedVariant!;
    if (selectedPriceListId != null &&
        v.priceListPrices.containsKey(selectedPriceListId)) {
      return v.priceListPrices[selectedPriceListId];
    }
    return v.basePrice;
  }

  /// Display label for the selected variant (e.g. "Large, Red").
  String? get selectedVariantLabel {
    if (selectedVariant == null || selectedVariant!.variableLabels.isEmpty)
      return null;
    return selectedVariant!.variableLabels.join(', ');
  }

  /// Total price of all selected addons (quantity * unit price per addon).
  double get selectedAddonsTotal {
    double total = 0;
    for (final addon in addons) {
      final qty = getAddonQuantity(addon.addonId);
      if (qty <= 0) continue;
      final unitPrice = selectedVariant != null
          ? (selectedVariant!.addonPrices[addon.addonId] ?? addon.price)
          : addon.price;
      total += unitPrice * qty;
    }
    return total;
  }

  /// Grand total: variant price + selected addons total (0 if no variant).
  double get orderLineTotal =>
      (selectedVariantPrice ?? 0) + selectedAddonsTotal;

  /// Sets addon quantity (0 = remove). Persists for the next step.
  void setAddonQuantity(int addonId, int quantity) {
    if (quantity <= 0) {
      addonQuantities.remove(addonId);
    } else {
      addonQuantities[addonId] = quantity;
    }
    if (state is CreateOrderProductLoaded) {
      emit(CreateOrderProductLoaded());
    }
  }

  /// Increments addon quantity by 1.
  void incrementAddon(int addonId) {
    setAddonQuantity(addonId, getAddonQuantity(addonId) + 1);
  }

  /// Decrements addon quantity by 1 (no lower than 0).
  void decrementAddon(int addonId) {
    final qty = getAddonQuantity(addonId);
    if (qty > 0) setAddonQuantity(addonId, qty - 1);
  }

  void _clearProductData() {
    errorMessage = null;
    product = null;
    variants = [];
    variableGroups = [];
    addons = [];
    priceLists = [];
    selectedPriceListId = null;
    selectedVariant = null;
    selectedValueIds.clear();
    addonQuantities.clear();
  }

  String priceListName(int id) {
    for (final pl in priceLists) {
      if (pl.id == id)
        return pl.name ??
            'create_order.price_list_id'.tr(namedArgs: {'id': '$id'});
    }
    return 'create_order.price_list_id'.tr(namedArgs: {'id': '$id'});
  }

  String addonName(int addonId) {
    for (final a in addons) {
      if (a.addonId == addonId) return a.name;
    }
    return 'create_order.addon_id'.tr(namedArgs: {'id': '$addonId'});
  }

  /// Fetches product by id; on failure or not found, sets [errorMessage], emits [CreateOrderError] and returns null.
  Future<ProductModel?> _loadProduct(int productId) async {
    final result = await _repo.getProductById(productId);
    return result.fold(
      (failure) {
        errorMessage =
            failure.failureMessage ?? 'create_order.unknown_error'.tr();
        emit(CreateOrderError());
        return null;
      },
      (p) {
        if (p == null) {
          errorMessage = 'create_order.product_not_found'.tr();
          emit(CreateOrderError());
          return null;
        }
        return p;
      },
    );
  }

  /// Fetches variants for product; on failure sets [errorMessage], emits [CreateOrderError] and returns null.
  Future<List<CreateOrderVariantModel>?> _loadVariants(int productId) async {
    final result = await _repo.getVariantsByProductId(productId);
    return result.fold((failure) {
      errorMessage =
          failure.failureMessage ?? 'create_order.load_variants_failed'.tr();
      emit(CreateOrderError());
      return null;
    }, (list) => list);
  }

  /// Fetches addons for product; on failure sets [errorMessage], emits [CreateOrderError] and returns null.
  Future<List<CreateOrderAddonModel>?> _loadAddons(int productId) async {
    final result = await _repo.getAddonsByProductId(productId);
    return result.fold((failure) {
      errorMessage =
          failure.failureMessage ?? 'create_order.load_addons_failed'.tr();
      emit(CreateOrderError());
      return null;
    }, (list) => list);
  }
}
