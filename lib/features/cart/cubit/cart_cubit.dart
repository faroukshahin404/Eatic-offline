import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/flutter_secure_storage.dart';
import '../../../core/services/windows_thermal_printer_service.dart';
import '../../../core/utils/app_utils.dart';
import '../../branches/model/branch_model.dart';
import '../../branches/repos/offline/branches_offline_repos.dart';
import '../../create_order/repos/offline/create_order_offline_repos.dart';
import '../../create_order/model/create_order_line_model.dart';
import '../../general_settings/general_settings_keys.dart';
import '../../general_settings/repos/offline/general_settings_offline_repos.dart';
import '../../add_customers/model/address_model.dart';
import '../../add_new_product/model/product_model.dart';
import '../../customers/model/customer_address_row.dart';
import '../../customers/repos/offline/customers_offline_repos.dart';
import '../../custody/repos/offline/custody_offline_repos.dart';
import '../../payment_methods/model/payment_method_model.dart';
import '../../payment_methods/repos/offline/payment_methods_offline_repos.dart';
import '../../price_lists/repos/offline/price_lists_offline_repos.dart';
import '../orders/model/order_model.dart';
import '../orders/repos/offline/orders_offline_repos.dart';
import '../../restaurant_tables/repos/offline/restaurant_tables_offline_repos.dart';
import '../../users/model/user_model.dart';
import '../../zones/repos/offline/zones_offline_repos.dart';
import '../services/order_receipt_service.dart';
import 'cart_state.dart';

/// Fallback payment method when list is empty or load fails. id is null (saved as null = Cash on order).
const PaymentMethodModel _cashFallback = PaymentMethodModel(
  id: null,
  vendorId: null,
  name: 'Cash',
  createdBy: null,
  createdAt: null,
  updatedAt: null,
);

class _CartRuntimeSettings {
  const _CartRuntimeSettings({
    required this.enabledOrderTypeIds,
    required this.defaultOrderTypeId,
    required this.customerPrintCount,
    required this.kitchenPrintCount,
    required this.customerPrinterName,
    required this.kitchenPrinterName,
    required this.taxPercentage,
    required this.restaurantName,
    required this.footerSlogan,
    required this.receiptLogoPath,
    required this.receiptFooterImagePath,
  });

  final List<int> enabledOrderTypeIds;
  final int defaultOrderTypeId;
  final int customerPrintCount;
  final int kitchenPrintCount;
  final String? customerPrinterName;
  final String? kitchenPrinterName;
  final double taxPercentage;
  final String? restaurantName;
  final String? footerSlogan;
  final String? receiptLogoPath;
  final String? receiptFooterImagePath;
}

class CartCubit extends Cubit<CartState> {
  CartCubit(
    this.custodyRepo,
    this.ordersRepo,
    this.paymentMethodsRepo,
    this.restaurantTablesRepo,
    this.generalSettingsRepo,
    this.branchesRepo,
    this.customersRepo,
    this.zonesRepo,
    this.priceListsRepo,
    this.createOrderRepo,
  ) : super(const CartState());

  final CustodyOfflineRepository custodyRepo;
  final OrdersOfflineRepository ordersRepo;
  final PaymentMethodsOfflineRepository paymentMethodsRepo;
  final RestaurantTablesOfflineRepository restaurantTablesRepo;
  final GeneralSettingsOfflineRepository generalSettingsRepo;
  final BranchesOfflineRepository branchesRepo;
  final CustomersOfflineRepository customersRepo;
  final ZonesOfflineRepository zonesRepo;
  final PriceListsOfflineRepository priceListsRepo;
  final CreateOrderOfflineRepository createOrderRepo;
  final OrderReceiptService _receiptService = OrderReceiptService(
    WindowsThermalPrinterService(),
  );

  /// Keeps the original persisted order snapshot during edit mode so we can
  /// preserve record id and printing/pending flags.
  OrderModel? _editingOrderSnapshot;

  /// Reads stored user from secure storage (logged-in cashier). Returns null if not found or invalid.
  Future<UserModel?> _getStoredUser() async {
    try {
      final userJson = await SecureLocalStorageService.readSecureData('user');
      if (userJson.isEmpty) return null;
      final decoded = jsonDecode(userJson);
      if (decoded is! Map<String, dynamic>) return null;
      return UserModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadOrderTypes() async {
    emit(state.copyWith(screenState: ScreenState.loading));
    final settings = await _loadRuntimeSettings();
    final result = await ordersRepo.getOrderTypes();
    result.fold(
      (_) {
        emit(state.copyWith(screenState: ScreenState.error, orderTypes: []));
      },
      (list) {
        final filtered =
            list
                .where((e) => settings.enabledOrderTypeIds.contains(e.id))
                .toList();
        final effectiveList = filtered.isEmpty ? list : filtered;
        final selectedOrderTypeId =
            effectiveList.any((e) => e.id == settings.defaultOrderTypeId)
                ? settings.defaultOrderTypeId
                : effectiveList.first.id;
        emit(
          state.copyWith(
            screenState: ScreenState.loaded,
            orderTypes: effectiveList,
            selectedOrderTypeIndex: selectedOrderTypeId,
          ),
        );
      },
    );
  }

  /// Computes discount amount from cart discount state and subtotal.
  static double _computeDiscountValue(CartState state, double subtotal) {
    switch (state.selectedDiscountType) {
      case CartDiscountType.amount:
        return (state.discountAmount ?? 0).clamp(0.0, subtotal);
      case CartDiscountType.percentage:
        final pct = state.discountPercentage ?? 0;
        if (pct <= 0 || pct > 100) return 0;
        return subtotal * (pct / 100);
      case CartDiscountType.coupon:
        return 0;
      case null:
        return 0;
    }
  }

  Future<_CartRuntimeSettings> _loadRuntimeSettings() async {
    final mapResult = await generalSettingsRepo.getAllAsMap();
    return mapResult.fold((_) => _defaultRuntimeSettings(), (map) {
      final enabledOrderTypesRaw =
          map[GeneralSettingsKeys.availableOrderTypes] ??
          'hall,takeaway,delivery';
      final enabledOrderTypeIds =
          enabledOrderTypesRaw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .map(_orderTypeNameToId)
              .whereType<int>()
              .toList();
      final defaultOrderTypeName =
          map[GeneralSettingsKeys.defaultOrderType] ?? 'hall';
      final defaultOrderTypeId = _orderTypeNameToId(defaultOrderTypeName) ?? 0;
      final customerPrintCount =
          int.tryParse(
            map[GeneralSettingsKeys.customerInvoicePrintCount] ?? '',
          ) ??
          1;
      final kitchenPrintCount =
          int.tryParse(
            map[GeneralSettingsKeys.kitchenInvoicePrintCount] ?? '',
          ) ??
          1;
      final taxPercentage =
          double.tryParse(map[GeneralSettingsKeys.taxPercentage] ?? '') ?? 0;
      final customerPrinterName =
          (map[GeneralSettingsKeys.customerPrinterName] ?? '').trim();
      final kitchenPrinterName =
          (map[GeneralSettingsKeys.kitchenPrinterName] ?? '').trim();
      final restaurantName =
          (map[GeneralSettingsKeys.restaurantName] ?? '').trim();
      final footerSlogan =
          (map[GeneralSettingsKeys.receiptFooterSlogan] ?? '').trim();
      final receiptLogoPath =
          (map[GeneralSettingsKeys.receiptLogoPath] ?? '').trim();
      final receiptFooterImagePath =
          (map[GeneralSettingsKeys.receiptFooterImagePath] ?? '').trim();

      return _CartRuntimeSettings(
        enabledOrderTypeIds:
            enabledOrderTypeIds.isEmpty ? const [0, 1, 2] : enabledOrderTypeIds,
        defaultOrderTypeId: defaultOrderTypeId,
        customerPrintCount: customerPrintCount < 1 ? 1 : customerPrintCount,
        kitchenPrintCount: kitchenPrintCount < 1 ? 1 : kitchenPrintCount,
        customerPrinterName:
            customerPrinterName.isEmpty ? null : customerPrinterName,
        kitchenPrinterName:
            kitchenPrinterName.isEmpty ? null : kitchenPrinterName,
        taxPercentage: taxPercentage < 0 ? 0 : taxPercentage,
        restaurantName: restaurantName.isEmpty ? null : restaurantName,
        footerSlogan: footerSlogan.isEmpty ? null : footerSlogan,
        receiptLogoPath: receiptLogoPath.isEmpty ? null : receiptLogoPath,
        receiptFooterImagePath:
            receiptFooterImagePath.isEmpty ? null : receiptFooterImagePath,
      );
    });
  }

  _CartRuntimeSettings _defaultRuntimeSettings() {
    return const _CartRuntimeSettings(
      enabledOrderTypeIds: [0, 1, 2],
      defaultOrderTypeId: 0,
      customerPrintCount: 1,
      kitchenPrintCount: 1,
      customerPrinterName: null,
      kitchenPrinterName: null,
      taxPercentage: 0,
      restaurantName: null,
      footerSlogan: null,
      receiptLogoPath: null,
      receiptFooterImagePath: null,
    );
  }

  int? _orderTypeNameToId(String name) {
    switch (name.trim().toLowerCase()) {
      case 'hall':
        return 0;
      case 'takeaway':
        return 1;
      case 'delivery':
        return 2;
      default:
        return null;
    }
  }

  String _orderTypeNameAr(int id) {
    switch (id) {
      case 0:
        return 'صالة';
      case 1:
        return 'تيك اواي';
      case 2:
        return 'توصيل';
      default:
        return '-';
    }
  }

  void setWaiter(UserModel? user) {
    emit(state.copyWith(selectedWaiter: user, clearWaiter: user == null));
  }

  void setTableNumber(String? tableNumber) {
    emit(state.copyWith(tableNumber: tableNumber));
  }

  void setSelectedTableId(int? tableId) {
    emit(state.copyWith(selectedTableId: tableId));
  }

  void setSelectedCustomer(CustomerAddressRow? customer) {
    emit(
      state.copyWith(
        selectedCustomer: customer,
        clearSelectedCustomer: customer == null,
        selectedCustomerId: customer?.customerId,
        clearSelectedCustomerId: customer == null,
        customerAddresses: customer == null ? const [] : [customer],
        clearCustomerAddresses: customer == null,
      ),
    );
  }

  Future<void> loadCustomerZones() async {
    final user = await _getStoredUser();
    final branchId = user?.branchId;
    if (branchId == null) {
      emit(state.copyWith(customerZones: const []));
      return;
    }
    final result = await zonesRepo.getZonesByBranchId(branchId);
    result.fold(
      (_) => emit(state.copyWith(customerZones: const [])),
      (zones) => emit(state.copyWith(customerZones: zones)),
    );
  }

  Future<void> searchCustomerSuggestions(String phoneInput) async {
    final phone = phoneInput.trim();
    if (phone.length < 7) {
      emit(
        state.copyWith(
          clearCustomerSuggestions: true,
          isCustomerLookupLoading: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isCustomerLookupLoading: true));
    final user = await _getStoredUser();
    final result = await customersRepo.getCustomerAddresses(
      branchId: user?.branchId,
      phone: phone,
    );
    result.fold(
      (_) => emit(
        state.copyWith(
          clearCustomerSuggestions: true,
          isCustomerLookupLoading: false,
        ),
      ),
      (rows) => emit(
        state.copyWith(
          customerSuggestions: _uniqueCustomers(rows),
          isCustomerLookupLoading: false,
        ),
      ),
    );
  }

  void clearCustomerSuggestions() {
    emit(state.copyWith(clearCustomerSuggestions: true));
  }

  Future<void> selectCustomerFromSuggestion(CustomerAddressRow row) async {
    emit(
      state.copyWith(
        selectedCustomerId: row.customerId,
        clearCustomerSuggestions: true,
      ),
    );
    await loadCustomerAddressesForCustomer(
      customerId: row.customerId,
      preferredAddressId: row.addressId,
    );
  }

  void selectCustomerAddress(int addressId) {
    final rows = state.customerAddresses;
    final selected = rows.where((r) => r.addressId == addressId).firstOrNull;
    if (selected == null) return;
    emit(
      state.copyWith(
        selectedCustomer: selected,
        selectedCustomerId: selected.customerId,
      ),
    );
  }

  Future<void> loadCustomerAddressesForCustomer({
    required int customerId,
    int? preferredAddressId,
  }) async {
    final result = await customersRepo.getCustomerById(customerId);
    result.fold(
      (_) => emit(
        state.copyWith(
          customerAddresses: const [],
          selectedCustomer: null,
          selectedCustomerId: customerId,
        ),
      ),
      (rows) {
        if (rows.isEmpty) {
          emit(
            state.copyWith(
              customerAddresses: const [],
              selectedCustomer: null,
              selectedCustomerId: customerId,
            ),
          );
          return;
        }
        CustomerAddressRow selected;
        if (preferredAddressId != null) {
          selected =
              rows
                  .where((r) => r.addressId == preferredAddressId)
                  .firstOrNull ??
              rows.first;
        } else {
          selected = rows.where((r) => r.isDefault).firstOrNull ?? rows.first;
        }
        emit(
          state.copyWith(
            customerAddresses: rows,
            selectedCustomer: selected,
            selectedCustomerId: customerId,
          ),
        );
      },
    );
  }

  Future<String?> addCustomer({
    required String name,
    required String phone,
  }) async {
    emit(state.copyWith(isCustomerAddressSaving: true));
    final result = await customersRepo.insertCustomer(name: name, phone: phone);
    return result.fold(
      (f) {
        emit(state.copyWith(isCustomerAddressSaving: false));
        return f.failureMessage ?? 'Failed to add customer';
      },
      (id) {
        emit(
          state.copyWith(
            isCustomerAddressSaving: false,
            selectedCustomerId: id,
            selectedCustomer: null,
            clearCustomerAddresses: true,
            clearCustomerSuggestions: true,
          ),
        );
        return null;
      },
    );
  }

  Future<String?> addAddressForSelectedCustomer(AddressModel address) async {
    final customerId =
        state.selectedCustomerId ?? state.selectedCustomer?.customerId;
    if (customerId == null) return 'Please select customer first';
    emit(state.copyWith(isCustomerAddressSaving: true));
    final result = await customersRepo.insertAddress(
      customerId: customerId,
      address: address,
    );
    return await result.fold(
      (f) async {
        emit(state.copyWith(isCustomerAddressSaving: false));
        return f.failureMessage ?? 'Failed to add address';
      },
      (addressId) async {
        await loadCustomerAddressesForCustomer(
          customerId: customerId,
          preferredAddressId: addressId,
        );
        emit(state.copyWith(isCustomerAddressSaving: false));
        return null;
      },
    );
  }

  Future<String?> updateAddressForSelectedCustomer({
    required int addressId,
    required AddressModel address,
  }) async {
    final customerId =
        state.selectedCustomerId ?? state.selectedCustomer?.customerId;
    if (customerId == null) return 'Please select customer first';
    emit(state.copyWith(isCustomerAddressSaving: true));
    final result = await customersRepo.updateAddress(
      addressId: addressId,
      address: address,
    );
    return await result.fold(
      (f) async {
        emit(state.copyWith(isCustomerAddressSaving: false));
        return f.failureMessage ?? 'Failed to update address';
      },
      (_) async {
        await loadCustomerAddressesForCustomer(
          customerId: customerId,
          preferredAddressId: addressId,
        );
        emit(state.copyWith(isCustomerAddressSaving: false));
        return null;
      },
    );
  }

  Future<String?> deleteAddressForSelectedCustomer(int addressId) async {
    final customerId =
        state.selectedCustomerId ?? state.selectedCustomer?.customerId;
    if (customerId == null) return 'Please select customer first';
    if (state.customerAddresses.length <= 1) {
      return 'At least one address is required for the customer';
    }
    emit(state.copyWith(isCustomerAddressSaving: true));
    final result = await customersRepo.deleteAddress(addressId);
    return await result.fold(
      (f) async {
        emit(state.copyWith(isCustomerAddressSaving: false));
        return f.failureMessage ?? 'Failed to delete address';
      },
      (_) async {
        await loadCustomerAddressesForCustomer(customerId: customerId);
        emit(state.copyWith(isCustomerAddressSaving: false));
        return null;
      },
    );
  }

  void clearSelectedCustomerFlow() {
    emit(
      state.copyWith(
        clearSelectedCustomer: true,
        clearSelectedCustomerId: true,
        clearCustomerAddresses: true,
        clearCustomerSuggestions: true,
      ),
    );
  }

  List<CustomerAddressRow> _uniqueCustomers(List<CustomerAddressRow> rows) {
    final byCustomerId = <int, CustomerAddressRow>{};
    for (final row in rows) {
      if (!byCustomerId.containsKey(row.customerId) || row.isDefault) {
        byCustomerId[row.customerId] = row;
      }
    }
    return byCustomerId.values.toList()
      ..sort((a, b) => a.customerId.compareTo(b.customerId));
  }

  void clearCart() {
    _editingOrderSnapshot = null;
    emit(
      state.copyWith(
        items: [],
        clearEditMode: true,
        clearSubmitError: true,
        submitSuccess: false,
        clearWaiter: true,
        clearSelectedCustomer: true,
        clearSelectedCustomerId: true,
        clearCustomerAddresses: true,
        clearCustomerSuggestions: true,
        clearTableNumber: true,
        clearSelectedTableId: true,
        clearDiscount: true,
      ),
    );
  }

  /// Starts edit mode by loading an existing order (with lines and resolved
  /// related entities) into the cart state.
  Future<void> startEditOrder(int orderId) async {
    _editingOrderSnapshot = null;
    emit(
      state.copyWith(
        clearSubmitError: true,
        submitSuccess: false,
        isEditMode: true,
        editingOrderId: orderId,
        items: const [],
        // Keep selections; they will be replaced when data loads.
      ),
    );

    final result = await ordersRepo.getOrderForCartEdit(orderId);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            clearEditMode: true,
            isSubmitting: false,
            submitError: failure.failureMessage ?? 'Failed to load order',
          ),
        );
      },
      (editModel) {
        _editingOrderSnapshot = editModel.order;

        final dtoOrder = editModel.order;
        if (dtoOrder.isPrinted == 1) {
          _editingOrderSnapshot = null;
          emit(
            state.copyWith(
              clearEditMode: true,
              isSubmitting: false,
              submitError: 'cart.order_already_printed'.tr(),
            ),
          );
          return;
        }
        final cartItems =
            (dtoOrder.items ?? []).map((line) {
              return CreateOrderLineModel(
                productId: line.productId,
                productName: line.productName,
                variantId: line.variantId,
                variantLabel: line.variantLabel,
                selectedOptions: const [],
                notes: line.notes ?? '',
                quantity: line.quantity,
                priceListId: line.priceListId,
                variantUnitPrice: line.unitPrice,
                addonQuantities: const {},
                addonsTotal: line.addonsTotal,
                lineTotal: line.lineTotal,
              );
            }).toList();

        final isDineIn = dtoOrder.orderType == 0;

        // Convert persisted discount amount to cart's discount state.
        emit(
          state.copyWith(
            isEditMode: true,
            editingOrderId: orderId,
            items: cartItems,
            selectedOrderTypeIndex: dtoOrder.orderType,
            selectedWaiter: isDineIn ? editModel.waiterUser : null,
            selectedTableId: isDineIn ? dtoOrder.tableId : null,
            tableNumber: isDineIn ? dtoOrder.tableNumber : null,
            selectedCustomer: isDineIn ? null : editModel.customerAddress,
            selectedCustomerId:
                isDineIn
                    ? null
                    : (editModel.customerAddress?.customerId ??
                        dtoOrder.customerId),
            customerAddresses:
                isDineIn
                    ? const []
                    : (editModel.customerAddress != null
                        ? [editModel.customerAddress!]
                        : const []),
            selectedPaymentMethod: editModel.paymentMethod,
            selectedDiscountType: CartDiscountType.amount,
            discountAmount: dtoOrder.discountAmount,
            discountPercentage: null,
            discountCouponCode: null,
            isSubmitting: false,
            clearSubmitError: true,
            submitSuccess: false,
          ),
        );
        if (!isDineIn && (editModel.customerAddress?.customerId != null)) {
          loadCustomerAddressesForCustomer(
            customerId: editModel.customerAddress!.customerId,
            preferredAddressId: editModel.customerAddress!.addressId,
          );
        }
      },
    );
  }

  void setOrderType(int id) {
    emit(state.copyWith(selectedOrderTypeIndex: id));
  }

  void addItem(CreateOrderLineModel line) {
    emit(state.copyWith(items: [...state.items, line]));
  }

  Future<void> loadOrderPriceLists() async {
    final result = await priceListsRepo.getAll();
    result.fold((_) => emit(state.copyWith(orderPriceLists: const [])), (list) {
      final valid = list.where((p) => p.id != null).toList();
      final currentId = state.selectedOrderPriceListId;
      final selectedId =
          currentId != null && valid.any((p) => p.id == currentId)
              ? currentId
              : valid.firstOrNull?.id;
      emit(
        state.copyWith(
          orderPriceLists: valid,
          selectedOrderPriceListId: selectedId,
        ),
      );
    });
  }

  void setSelectedOrderPriceListId(int? id) {
    emit(state.copyWith(selectedOrderPriceListId: id));
  }

  Future<String?> addSimpleProductToCart(ProductModel product) async {
    if (product.id == null) return 'Invalid product';
    var unitPrice = product.defaultPrice ?? 0.0;
    final selectedPriceListId = state.selectedOrderPriceListId;
    if (selectedPriceListId != null) {
      final priceResult = await createOrderRepo.getProductPriceListPrices(
        product.id!,
      );
      unitPrice = priceResult.fold(
        (_) => unitPrice,
        (map) => map[selectedPriceListId] ?? unitPrice,
      );
    }

    final line = CreateOrderLineModel(
      productId: product.id!,
      productName: product.name ?? '',
      selectedOptions: const [],
      selectedAddons: const [],
      notes: '',
      quantity: 1,
      priceListId: selectedPriceListId,
      variantUnitPrice: unitPrice,
      addonQuantities: const {},
      addonsTotal: 0,
      lineTotal: unitPrice,
    );
    addItem(line);
    return null;
  }

  void incrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    final updated = line.copyWith(quantity: line.quantity + 1);
    final newItems = List<CreateOrderLineModel>.from(state.items)
      ..[index] = updated;
    emit(state.copyWith(items: newItems));
  }

  void decrementQuantity(int index) {
    if (index < 0 || index >= state.items.length) return;
    final line = state.items[index];
    if (line.quantity <= 1) {
      final newItems = List<CreateOrderLineModel>.from(state.items)
        ..removeAt(index);
      emit(state.copyWith(items: newItems));
      return;
    }
    final updated = line.copyWith(quantity: line.quantity - 1);
    final newItems = List<CreateOrderLineModel>.from(state.items)
      ..[index] = updated;
    emit(state.copyWith(items: newItems));
  }

  void setSelectedPaymentMethod(PaymentMethodModel? value) {
    emit(state.copyWith(selectedPaymentMethod: value));
  }

  /// Loads payment methods from repo. On empty or failure, uses Cash fallback so UI and order always have a value.
  Future<void> loadPaymentMethods() async {
    final result = await paymentMethodsRepo.getAll();
    result.fold(
      (_) {
        emit(
          state.copyWith(
            paymentMethods: [_cashFallback],
            selectedPaymentMethod: state.selectedPaymentMethod ?? _cashFallback,
          ),
        );
      },
      (list) {
        final effectiveList = list.isEmpty ? [_cashFallback] : list;
        final current = state.selectedPaymentMethod;
        final selected =
            current != null &&
                    effectiveList.any((p) => p.id != null && p.id == current.id)
                ? current
                : effectiveList.first;
        emit(
          state.copyWith(
            paymentMethods: effectiveList,
            selectedPaymentMethod: selected,
          ),
        );
      },
    );
  }

  /// Refreshes [hasOpenCustody] from [CustodyOfflineRepository.getLastOpenCustody]. Call after cart is shown or after open/close custody dialogs complete.
  Future<void> refreshHasOpenCustody() async {
    final result = await custodyRepo.getLastOpenCustody();
    final hasOpen = result.fold((_) => false, (v) => v != null);
    emit(state.copyWith(hasOpenCustody: hasOpen));
  }

  void setDiscountByAmount(double? value) {
    emit(
      state.copyWith(
        selectedDiscountType: CartDiscountType.amount,
        discountAmount: value,
        discountPercentage: null,
        discountCouponCode: null,
      ),
    );
  }

  void setDiscountByPercentage(double? value) {
    emit(
      state.copyWith(
        selectedDiscountType: CartDiscountType.percentage,
        discountPercentage: value,
        discountAmount: null,
        discountCouponCode: null,
      ),
    );
  }

  // Coupon discount temporarily disabled.
  // void setDiscountByCoupon(String? code) {
  //   emit(state.copyWith(
  //     selectedDiscountType: CartDiscountType.coupon,
  //     discountCouponCode: code,
  //     discountAmount: null,
  //     discountPercentage: null,
  //   ));
  // }

  void clearDiscount() {
    emit(state.copyWith(clearDiscount: true));
  }

  bool _validateDeliveryCustomerAddressSelection() {
    const orderTypeDelivery = 2;
    if (state.selectedOrderTypeIndex != orderTypeDelivery) return true;
    if ((state.selectedCustomer?.customerId ?? state.selectedCustomerId) ==
        null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: 'cart.delivery_customer_required'.tr(),
        ),
      );
      return false;
    }
    if (state.selectedCustomer?.addressId == null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: 'cart.delivery_address_required'.tr(),
        ),
      );
      return false;
    }
    return true;
  }

  /// Submits the cart as an order: saves order + lines, optional customer/table/waiter, and marks table occupied for dine-in.
  /// Requires: items not empty, logged-in user (cashier), open custody. For dine-in also requires waiter and table.
  /// Emits [isSubmitting] during run and [submitError] on failure; on success clears cart and [submitError].
  Future<void> submitOrder({bool printAfterSubmit = false}) async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));

    if (state.items.isEmpty) {
      emit(state.copyWith(isSubmitting: false, submitError: 'Cart is empty'));
      return;
    }

    final runtimeSettings = await _loadRuntimeSettings();

    // Edit mode: update the selected pending order instead of inserting a new one.
    if (state.isEditMode && state.editingOrderId != null) {
      final snapshot = _editingOrderSnapshot;
      if (snapshot == null || snapshot.id == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError: 'Failed to load order for editing',
            clearEditMode: true,
          ),
        );
        return;
      }
      if (snapshot.id != state.editingOrderId) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError: 'Selected order does not match loaded snapshot',
            clearEditMode: true,
          ),
        );
        return;
      }

      const orderTypeDineIn = 0;
      if (state.selectedOrderTypeIndex == orderTypeDineIn) {
        if (state.selectedWaiter == null || state.selectedWaiter!.id == null) {
          emit(
            state.copyWith(
              isSubmitting: false,
              submitError: 'Please select a waiter for dine-in orders.',
            ),
          );
          return;
        }
        if (state.selectedTableId == null) {
          emit(
            state.copyWith(
              isSubmitting: false,
              submitError: 'Please select a table for dine-in orders.',
            ),
          );
          return;
        }
      }
      if (!_validateDeliveryCustomerAddressSelection()) return;

      final subtotal = state.items.fold<double>(
        0,
        (sum, line) => sum + line.lineTotal,
      );
      final discountValue = _computeDiscountValue(state, subtotal);
      final total = (subtotal - discountValue).clamp(0.0, double.infinity);

      final updatedOrder = OrderModel(
        id: snapshot.id,
        selectedPriceListId: state.items.first.priceListId ?? 0,
        custodyId: snapshot.custodyId,
        cashierId: snapshot.cashierId,
        orderType: state.selectedOrderTypeIndex,
        tableId:
            state.selectedOrderTypeIndex == orderTypeDineIn
                ? state.selectedTableId
                : null,
        tableNumber:
            state.selectedOrderTypeIndex == orderTypeDineIn
                ? state.tableNumber
                : null,
        waiterId:
            state.selectedOrderTypeIndex == orderTypeDineIn
                ? state.selectedWaiter!.id
                : null,
        customerId:
            state.selectedCustomer?.customerId ?? state.selectedCustomerId,
        addressId: state.selectedCustomer?.addressId,
        paymentMethodId: state.selectedPaymentMethod?.id,
        subtotal: subtotal,
        discountAmount: discountValue,
        total: total,
        createdAt: snapshot.createdAt,
        isPending: snapshot.isPending,
        isPrinted: snapshot.isPrinted,
        isPrintedToCustomer: snapshot.isPrintedToCustomer,
        isPrintedToKitchen: snapshot.isPrintedToKitchen,
      );

      final orderUpdate = await ordersRepo.updateOrder(updatedOrder);
      final orderOk = orderUpdate.fold<bool>((failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError: failure.failureMessage ?? 'Failed to update order',
          ),
        );
        return false;
      }, (_) => true);
      if (!orderOk) return;

      final linesResult = await ordersRepo.updateOrderLines(
        state.editingOrderId!,
        state.items,
      );
      final linesOk = linesResult.fold<bool>((failure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError:
                failure.failureMessage ?? 'Failed to save updated order lines',
          ),
        );
        return false;
      }, (_) => true);
      if (!linesOk) return;

      String? printErrorMessage;
      if (printAfterSubmit) {
        final currentUser = await _getStoredUser();
        final printResult = await _printSavedOrder(
          orderId: state.editingOrderId!,
          cashierBranchId: currentUser?.branchId,
          createdAt: snapshot.createdAt ?? DateTime.now().toIso8601String(),
          runtimeSettings: runtimeSettings,
        );
        printErrorMessage = printResult.$3;
        await ordersRepo.updateOrderPrintFlags(
          orderId: state.editingOrderId!,
          printedToCustomer: printResult.$1,
          printedToKitchen: printResult.$2,
        );
      }

      if (state.selectedOrderTypeIndex == orderTypeDineIn &&
          state.selectedTableId != null) {
        final tableResult = await restaurantTablesRepo.updateTableIsEmpty(
          state.selectedTableId!,
          0,
        );
        await tableResult.fold(
          (failure) async {
            emit(
              state.copyWith(
                isSubmitting: false,
                submitError:
                    failure.failureMessage ??
                    'Order updated but failed to update table status',
              ),
            );
          },
          (_) async {
            emit(
              state.copyWith(
                items: [],
                isSubmitting: false,
                clearSubmitError: true,
                submitSuccess: true,
                clearEditMode: true,
                clearSelectedCustomer: true,
                clearSelectedCustomerId: true,
                clearCustomerAddresses: true,
                clearCustomerSuggestions: true,
                submitError: printErrorMessage,
              ),
            );
            _editingOrderSnapshot = null;
          },
        );
      } else {
        emit(
          state.copyWith(
            items: [],
            isSubmitting: false,
            clearSubmitError: true,
            submitSuccess: true,
            clearEditMode: true,
            clearSelectedCustomer: true,
            clearSelectedCustomerId: true,
            clearCustomerAddresses: true,
            clearCustomerSuggestions: true,
            submitError: printErrorMessage,
          ),
        );
        _editingOrderSnapshot = null;
      }

      return;
    }

    final cashier = await _getStoredUser();
    if (cashier == null || cashier.id == null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: 'No logged-in user. Please log in as cashier.',
        ),
      );
      return;
    }

    final custodyResult = await custodyRepo.getLastOpenCustody();
    final custody = custodyResult.fold((_) => null, (c) => c);
    if (custody == null || custody.id == null) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: 'No open custody. Please open a custody first.',
        ),
      );
      return;
    }

    const orderTypeDineIn = 0;
    if (state.selectedOrderTypeIndex == orderTypeDineIn) {
      if (state.selectedWaiter == null || state.selectedWaiter!.id == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError: 'Please select a waiter for dine-in orders.',
          ),
        );
        return;
      }
      if (state.selectedTableId == null) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError: 'Please select a table for dine-in orders.',
          ),
        );
        return;
      }
    }
    if (!_validateDeliveryCustomerAddressSelection()) return;

    final subtotal = state.items.fold<double>(
      0,
      (sum, line) => sum + line.lineTotal,
    );
    final discountValue = _computeDiscountValue(state, subtotal);
    final total = (subtotal - discountValue).clamp(0.0, double.infinity);

    final order = OrderModel(
      selectedPriceListId: state.items.first.priceListId ?? 0,
      custodyId: custody.id!,
      cashierId: cashier.id!,
      orderType: state.selectedOrderTypeIndex,
      tableId:
          state.selectedOrderTypeIndex == orderTypeDineIn
              ? state.selectedTableId
              : null,
      tableNumber:
          state.selectedOrderTypeIndex == orderTypeDineIn
              ? state.tableNumber
              : null,
      waiterId:
          state.selectedOrderTypeIndex == orderTypeDineIn
              ? state.selectedWaiter!.id
              : null,
      customerId:
          state.selectedCustomer?.customerId ?? state.selectedCustomerId,
      addressId: state.selectedCustomer?.addressId,
      paymentMethodId: state.selectedPaymentMethod?.id,
      subtotal: subtotal,
      discountAmount: discountValue,
      total: total,
    );

    final orderResult = await ordersRepo.insertOrder(order);
    final orderId = orderResult.fold<int?>((failure) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: failure.failureMessage ?? 'Failed to save order',
        ),
      );
      return null;
    }, (id) => id);
    if (orderId == null) return;

    final linesResult = await ordersRepo.insertOrderLines(orderId, state.items);
    final linesOk = linesResult.fold<bool>((failure) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: failure.failureMessage ?? 'Failed to save order lines',
        ),
      );
      return false;
    }, (_) => true);
    if (!linesOk) return;

    String? printErrorMessage;
    if (printAfterSubmit) {
      final printResult = await _printSavedOrder(
        orderId: orderId,
        cashierBranchId: cashier.branchId,
        createdAt: DateTime.now().toIso8601String(),
        runtimeSettings: runtimeSettings,
      );
      printErrorMessage = printResult.$3;
      await ordersRepo.updateOrderPrintFlags(
        orderId: orderId,
        printedToCustomer: printResult.$1,
        printedToKitchen: printResult.$2,
      );
    }

    if (state.selectedOrderTypeIndex == orderTypeDineIn &&
        state.selectedTableId != null) {
      final tableResult = await restaurantTablesRepo.updateTableIsEmpty(
        state.selectedTableId!,
        0,
      );
      tableResult.fold(
        (failure) {
          emit(
            state.copyWith(
              isSubmitting: false,
              submitError:
                  failure.failureMessage ??
                  'Order saved but failed to update table status',
            ),
          );
        },
        (_) {
          emit(
            state.copyWith(
              items: [],
              isSubmitting: false,
              clearSubmitError: true,
              submitSuccess: true,
              clearSelectedCustomer: true,
              clearSelectedCustomerId: true,
              clearCustomerAddresses: true,
              clearCustomerSuggestions: true,
              submitError: printErrorMessage,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          items: [],
          isSubmitting: false,
          clearSubmitError: true,
          submitSuccess: true,
          clearSelectedCustomer: true,
          clearSelectedCustomerId: true,
          clearCustomerAddresses: true,
          clearCustomerSuggestions: true,
          submitError: printErrorMessage,
        ),
      );
    }
  }

  Future<void> submitOrderAndPrint() async {
    await submitOrder(printAfterSubmit: true);
  }

  Future<String> _resolveBranchName(int? branchId) async {
    if (branchId == null) return '-';
    final result = await branchesRepo.getAll();
    return result.fold((_) => '-', (list) {
      BranchModel? branch;
      for (final b in list) {
        if (b.id == branchId) {
          branch = b;
          break;
        }
      }
      return branch?.name ?? '-';
    });
  }

  Future<(bool, bool, String?)> _printSavedOrder({
    required int orderId,
    required int? cashierBranchId,
    required String createdAt,
    required _CartRuntimeSettings runtimeSettings,
  }) async {
    final branchName = await _resolveBranchName(cashierBranchId);
    final subtotal = state.items.fold<double>(
      0,
      (sum, line) => sum + line.lineTotal,
    );
    final discountValue = _computeDiscountValue(state, subtotal);
    final customerReceiptText = _receiptService.buildCustomerArabicReceipt(
      orderId: orderId,
      createdAt: createdAt,
      branchName: branchName,
      orderTypeNameAr: _orderTypeNameAr(state.selectedOrderTypeIndex),
      items: state.items,
      subtotal: subtotal,
      discount: discountValue,
      taxPercentage: runtimeSettings.taxPercentage,
      customer: state.selectedCustomer,
      tableNumber: state.tableNumber,
      waiterName: state.selectedWaiter?.name ?? state.selectedWaiter?.code,
      restaurantName: runtimeSettings.restaurantName,
      footerSlogan: runtimeSettings.footerSlogan,
    );
    final kitchenReceiptText = _receiptService.buildKitchenArabicReceipt(
      orderId: orderId,
      createdAt: createdAt,
      orderTypeNameAr: _orderTypeNameAr(state.selectedOrderTypeIndex),
      items: state.items,
      tableNumber: state.tableNumber,
      waiterName: state.selectedWaiter?.name ?? state.selectedWaiter?.code,
    );

    var printedToCustomer = false;
    var printedToKitchen = false;
    final errors = <String>[];

    if (runtimeSettings.kitchenPrinterName != null) {
      final kitchenOk = await _receiptService.printReceipt(
        printerName: runtimeSettings.kitchenPrinterName!,
        receiptText: kitchenReceiptText,
        copies: runtimeSettings.kitchenPrintCount,
        fontSize: 13,
        paperWidthMm: 80,
        rightToLeft: true,
        headerImageMaxHeightPx: 120,
        footerImageMaxHeightPx: 80,
      );
      printedToKitchen = kitchenOk;
      if (!kitchenOk) {
        errors.add('تعذر طباعة فاتورة المطبخ');
      }
    } else {
      errors.add('لم يتم اختيار طابعة المطبخ');
    }

    if (runtimeSettings.customerPrinterName != null) {
      final customerOk = await _receiptService.printReceipt(
        printerName: runtimeSettings.customerPrinterName!,
        receiptText: customerReceiptText,
        copies: runtimeSettings.customerPrintCount,
        fontSize: 12,
        paperWidthMm: 80,
        rightToLeft: true,
        headerImagePath: runtimeSettings.receiptLogoPath,
        footerImagePath: runtimeSettings.receiptFooterImagePath,
        headerImageMaxHeightPx: 170,
        footerImageMaxHeightPx: 120,
      );
      printedToCustomer = customerOk;
      if (!customerOk) {
        errors.add('تعذر طباعة فاتورة العميل');
      }
    } else {
      errors.add('لم يتم اختيار طابعة العميل');
    }

    return (
      printedToCustomer,
      printedToKitchen,
      errors.isEmpty ? null : errors.join(' - '),
    );
  }

  /// Clears the one-shot [submitSuccess] flag after UI has shown feedback.
  void clearSubmitSuccess() {
    emit(state.copyWith(clearSubmitSuccess: true));
  }
}
