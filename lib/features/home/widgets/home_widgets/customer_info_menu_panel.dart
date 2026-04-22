import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button_widget.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../_main/cubit/main_cubit.dart';
import '../../../add_customers/model/address_model.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../cart/cubit/cart_state.dart';
import '../../../customers/model/customer_address_row.dart';
import '../../../zones/model/zone_model.dart';

class CustomerInfoMenuPanel extends StatefulWidget {
  const CustomerInfoMenuPanel({super.key});

  @override
  State<CustomerInfoMenuPanel> createState() => _CustomerInfoMenuPanelState();
}

class _CustomerInfoMenuPanelState extends State<CustomerInfoMenuPanel> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  Timer? _debounce;
  String? _selectedPhoneSnapshot;

  @override
  void initState() {
    super.initState();
    final selected = context.read<CartCubit>().state.selectedCustomer;
    _syncFromSelectedCustomer(selected);
  }

  void _syncFromSelectedCustomer(CustomerAddressRow? row) {
    if (row == null) return;
    _nameController.text =
        row.name?.trim().isNotEmpty == true ? row.name!.trim() : '';
    _phoneController.text = row.phone;
    _selectedPhoneSnapshot = row.phone.trim();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(BuildContext context, String value) {
    final cubit = context.read<CartCubit>();
    final normalized = value.trim();
    final selectedPhone = _selectedPhoneSnapshot;
    if (selectedPhone != null && selectedPhone != normalized) {
      _selectedPhoneSnapshot = null;
      cubit.clearSelectedCustomerFlow();
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      if (normalized.length >= 7) {
        cubit.searchCustomerSuggestions(normalized);
      } else {
        cubit.clearCustomerSuggestions();
      }
    });
  }

  Future<void> _onAddCustomerPressed() async {
    final cubit = context.read<CartCubit>();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      _showSnack(context, 'cart.customer_name_phone_required'.tr());
      return;
    }
    final error = await cubit.addCustomer(name: name, phone: phone);
    if (!mounted) return;
    if (error != null) {
      _showSnack(context, error);
      return;
    }
    _selectedPhoneSnapshot = phone;
    _showSnack(context, 'cart.customer_added'.tr());
  }

  Future<void> _onSuggestionSelected(
    BuildContext context,
    CustomerAddressRow row,
  ) async {
    _nameController.text =
        row.name?.trim().isNotEmpty == true ? row.name!.trim() : '';
    _phoneController.text = row.phone;
    _selectedPhoneSnapshot = row.phone.trim();
    await context.read<CartCubit>().selectCustomerFromSuggestion(row);
  }

  bool _showAddButton(CartState state) {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) return false;
    if (state.selectedCustomerId != null) return false;
    final exactMatch = state.customerSuggestions.any(
      (c) => c.phone.trim() == phone,
    );
    return !exactMatch;
  }

  String _addressSummary(CustomerAddressRow row) {
    String normalized(String? v) =>
        (v == null || v.trim().isEmpty) ? '-' : v.trim();
    return '${'customers.table.zone'.tr()}: ${normalized(row.zoneName)}'
        ' | ${'customers.table.building'.tr()}: ${normalized(row.buildingNumber)}'
        ' | ${'customers.table.floor'.tr()}: ${normalized(row.floor)}'
        ' | ${'customers.table.apartment'.tr()}: ${normalized(row.apartment)}';
  }

  Future<AddressModel?> _showAddressDialog(
    BuildContext context, {
    CustomerAddressRow? current,
  }) async {
    final state = context.read<CartCubit>().state;
    if (state.customerZones.isEmpty) {
      _showSnack(context, 'cart.no_zones_available'.tr());
      return null;
    }
    return showDialog<AddressModel>(
      context: context,
      builder:
          (ctx) => _AddressFormDialog(
            zones: state.customerZones,
            current: current,
            zoneRequiredMessage: 'customers.validation.zone_required'.tr(),
          ),
    );
  }

  Future<void> _onAddAddressPressed(BuildContext context) async {
    final model = await _showAddressDialog(context);
    if (model == null) return;
    if (!context.mounted) return;
    final error = await context.read<CartCubit>().addAddressForSelectedCustomer(
      model,
    );
    if (!context.mounted) return;
    if (error != null) {
      _showSnack(context, error);
      return;
    }
    _showSnack(context, 'cart.address_saved'.tr());
  }

  Future<void> _onEditAddressPressed(
    BuildContext context,
    CustomerAddressRow row,
  ) async {
    final model = await _showAddressDialog(context, current: row);
    if (model == null) return;
    if (!context.mounted) return;
    final error = await context
        .read<CartCubit>()
        .updateAddressForSelectedCustomer(
          addressId: row.addressId,
          address: model,
        );
    if (!context.mounted) return;
    if (error != null) {
      _showSnack(context, error);
      return;
    }
    _showSnack(context, 'cart.address_saved'.tr());
  }

  Future<void> _onDeleteAddressPressed(
    BuildContext context,
    CustomerAddressRow row,
  ) async {
    final cubit = context.read<CartCubit>();
    if (cubit.state.customerAddresses.length <= 1) {
      _showSnack(context, 'cart.keep_one_address_required'.tr());
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('actions.delete'.tr()),
            content: Text('cart.delete_address_confirm'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('cart.cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('actions.delete'.tr()),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await cubit.deleteAddressForSelectedCustomer(row.addressId);
    if (!context.mounted) return;
    if (error != null) {
      _showSnack(context, error);
      return;
    }
    _showSnack(context, 'cart.address_deleted'.tr());
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onConfirmPressed(BuildContext context, CartState state) {
    if (state.selectedCustomer == null) {
      _showSnack(context, 'cart.select_customer_address'.tr());
      return;
    }
    context.read<MainCubit>().setCustomerInfoPanelVisible(false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen:
          (p, c) =>
              p.customerSuggestions != c.customerSuggestions ||
              p.selectedCustomer != c.selectedCustomer ||
              p.selectedCustomerId != c.selectedCustomerId ||
              p.customerAddresses != c.customerAddresses ||
              p.isCustomerLookupLoading != c.isCustomerLookupLoading ||
              p.isCustomerAddressSaving != c.isCustomerAddressSaving,
      builder: (context, state) {
        _syncFromSelectedCustomer(state.selectedCustomer);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyE6E9EA),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'customers.phone',
                      hint: 'customers.phone',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      isOnlyNumbers: true,
                      onChanged: (value) => _onPhoneChanged(context, value),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            title: 'customers.name',
                            hint: 'customers.name',
                            controller: _nameController,
                          ),
                        ),
                        if (_showAddButton(state)) ...[
                          const SizedBox(width: 8),
                          CustomButtonWidget(
                            text: 'cart.add_customer_quick'.tr(),
                            onPressed:
                                state.isCustomerAddressSaving
                                    ? null
                                    : _onAddCustomerPressed,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (state.isCustomerLookupLoading) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(minHeight: 2),
              ],
              if (state.customerSuggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyE6E9EA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      for (final suggestion in state.customerSuggestions)
                        ListTile(
                          dense: true,
                          title: Text(
                            suggestion.name?.trim().isNotEmpty == true
                                ? suggestion.name!.trim()
                                : '-',
                          ),
                          subtitle: Text(suggestion.phone),
                          onTap:
                              () => _onSuggestionSelected(context, suggestion),
                        ),
                    ],
                  ),
                ),
              ],
              if (state.selectedCustomerId != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: 'cart.customer_addresses'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    CustomButtonWidget(
                      text: 'customers.add_address'.tr(),
                      onPressed:
                          state.isCustomerAddressSaving
                              ? null
                              : () => _onAddAddressPressed(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.customerAddresses.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.fillColor,
                      border: Border.all(color: AppColors.greyE6E9EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('cart.no_customer_addresses'.tr()),
                  )
                else
                  ...state.customerAddresses.map(
                    (address) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.greyE6E9EA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: address.addressId,
                            groupValue: state.selectedCustomer?.addressId,
                            onChanged:
                                (_) => context
                                    .read<CartCubit>()
                                    .selectCustomerAddress(address.addressId),
                          ),
                          Expanded(
                            child: Text(
                              _addressSummary(address),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'actions.edit'.tr(),
                            onPressed:
                                state.isCustomerAddressSaving
                                    ? null
                                    : () =>
                                        _onEditAddressPressed(context, address),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'actions.delete'.tr(),
                            onPressed:
                                state.isCustomerAddressSaving
                                    ? null
                                    : () => _onDeleteAddressPressed(
                                      context,
                                      address,
                                    ),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButtonWidget(
                    text: 'cart.confirm_customer_info'.tr(),
                    onPressed:
                        state.isCustomerAddressSaving
                            ? null
                            : () => _onConfirmPressed(context, state),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AddressFormDialog extends StatefulWidget {
  const _AddressFormDialog({
    required this.zones,
    required this.zoneRequiredMessage,
    this.current,
  });

  final List<ZoneModel> zones;
  final CustomerAddressRow? current;
  final String zoneRequiredMessage;

  @override
  State<_AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<_AddressFormDialog> {
  late final TextEditingController _apartmentController;
  late final TextEditingController _floorController;
  late final TextEditingController _buildingController;

  late ZoneModel _selectedZone;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final current = widget.current;
    _apartmentController = TextEditingController(
      text: current?.apartment ?? '',
    );
    _floorController = TextEditingController(text: current?.floor ?? '');
    _buildingController = TextEditingController(
      text: current?.buildingNumber ?? '',
    );
    _selectedZone =
        widget.zones.where((z) => z.id == current?.zoneId).firstOrNull ??
        widget.zones.first;
    _isDefault = current?.isDefault ?? false;
  }

  @override
  void dispose() {
    _apartmentController.dispose();
    _floorController.dispose();
    _buildingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.current == null
            ? 'cart.add_new_address'.tr()
            : 'cart.edit_address'.tr(),
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            spacing: 12,
            children: [
              CustomDropDown<ZoneModel>(
                items: widget.zones,
                value: _selectedZone,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedZone = v);
                },
                itemLabelBuilder: (z) => z.name ?? '-',
                label: 'customers.zone'.tr(),
              ),
              CustomTextField(
                title: 'customers.building_number',
                hint: 'customers.building_number',
                controller: _buildingController,
              ),
              CustomTextField(
                title: 'customers.floor',
                hint: 'customers.floor',
                controller: _floorController,
              ),
              CustomTextField(
                title: 'customers.apartment',
                hint: 'customers.apartment',
                controller: _apartmentController,
              ),
              CheckboxListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
                title: Text('customers.is_default'.tr()),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cart.cancel'.tr()),
        ),
        CustomButtonWidget(
          text: 'customers.save'.tr(),
          onPressed: () {
            if (_selectedZone.id == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.zoneRequiredMessage)),
              );
              return;
            }
            Navigator.of(context).pop(
              AddressModel(
                zoneId: _selectedZone.id!,
                apartment:
                    _apartmentController.text.trim().isEmpty
                        ? null
                        : _apartmentController.text.trim(),
                floor:
                    _floorController.text.trim().isEmpty
                        ? null
                        : _floorController.text.trim(),
                buildingNumber:
                    _buildingController.text.trim().isEmpty
                        ? null
                        : _buildingController.text.trim(),
                isDefault: _isDefault,
              ),
            );
          },
        ),
      ],
    );
  }
}
