import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../core/services/flutter_secure_storage.dart';
import '../../core/services/windows_printer_service.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_failed_widget.dart';
import '../../core/widgets/custom_loading.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services_locator/service_locator.dart';
import 'general_settings_keys.dart';
import 'repos/offline/general_settings_offline_repos.dart';
import '../users/model/user_model.dart';
import '../users/session_user_holder.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  static const String _hall = 'hall';
  static const String _takeaway = 'takeaway';
  static const String _delivery = 'delivery';

  final _formKey = GlobalKey<FormState>();
  final _customerPrintCountController = TextEditingController();
  final _kitchenPrintCountController = TextEditingController();
  final _taxPercentageController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _footerSloganController = TextEditingController();
  final GeneralSettingsOfflineRepository _repo =
      getIt<GeneralSettingsOfflineRepository>();
  final WindowsPrinterService _printerService = WindowsPrinterService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoadingPrinters = false;
  String? _errorMessage;

  bool _isHallEnabled = true;
  bool _isTakeawayEnabled = true;
  bool _isDeliveryEnabled = true;
  String _defaultOrderType = _hall;
  List<String> _availablePrinters = const [];
  String? _selectedCustomerPrinter;
  String? _selectedKitchenPrinter;
  String? _receiptLogoPath;
  String? _receiptFooterImagePath;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _customerPrintCountController.dispose();
    _kitchenPrintCountController.dispose();
    _taxPercentageController.dispose();
    _restaurantNameController.dispose();
    _footerSloganController.dispose();
    super.dispose();
  }

  Future<UserModel?> _getStoredUser() async {
    try {
      final userJson = await SecureLocalStorageService.readSecureData('user');
      if (userJson.isNotEmpty) {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) {
          final user = UserModel.fromJson(decoded);
          SessionUserHolder.current = user;
          return user;
        }
      }
    } catch (_) {}
    return SessionUserHolder.current;
  }

  List<String> _enabledOrderTypes() {
    final enabled = <String>[];
    if (_isHallEnabled) enabled.add(_hall);
    if (_isTakeawayEnabled) enabled.add(_takeaway);
    if (_isDeliveryEnabled) enabled.add(_delivery);
    return enabled;
  }

  void _ensureDefaultOrderTypeIsEnabled() {
    final enabled = _enabledOrderTypes();
    if (enabled.isEmpty) {
      _isHallEnabled = true;
      _defaultOrderType = _hall;
      return;
    }
    if (!enabled.contains(_defaultOrderType)) {
      _defaultOrderType = enabled.first;
    }
  }

  void _onOrderTypeChanged(String type, bool enabled) {
    setState(() {
      switch (type) {
        case _hall:
          _isHallEnabled = enabled;
          break;
        case _takeaway:
          _isTakeawayEnabled = enabled;
          break;
        case _delivery:
          _isDeliveryEnabled = enabled;
          break;
      }
      _ensureDefaultOrderTypeIsEnabled();
    });
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final printerNames = await _printerService.getActivePrinterNames();
    final result = await _repo.getAllAsMap();
    result.fold(
      (failure) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              failure.failureMessage ?? 'general_settings.load_failed';
          _isLoading = false;
        });
      },
      (settingsMap) {
        if (!mounted) return;
        final customerPrinterName =
            settingsMap[GeneralSettingsKeys.customerPrinterName];
        final kitchenPrinterName =
            settingsMap[GeneralSettingsKeys.kitchenPrinterName];

        _availablePrinters = printerNames;
        _selectedCustomerPrinter =
            (customerPrinterName != null &&
                    customerPrinterName.isNotEmpty &&
                    _availablePrinters.contains(customerPrinterName))
                ? customerPrinterName
                : null;
        _selectedKitchenPrinter =
            (kitchenPrinterName != null &&
                    kitchenPrinterName.isNotEmpty &&
                    _availablePrinters.contains(kitchenPrinterName))
                ? kitchenPrinterName
                : null;

        _customerPrintCountController.text =
            settingsMap[GeneralSettingsKeys.customerInvoicePrintCount] ?? '1';
        _kitchenPrintCountController.text =
            settingsMap[GeneralSettingsKeys.kitchenInvoicePrintCount] ?? '1';
        _taxPercentageController.text =
            settingsMap[GeneralSettingsKeys.taxPercentage] ?? '0';
        _restaurantNameController.text =
            settingsMap[GeneralSettingsKeys.restaurantName] ?? '';
        _footerSloganController.text =
            settingsMap[GeneralSettingsKeys.receiptFooterSlogan] ?? '';
        _receiptLogoPath = _sanitizeImagePath(
          settingsMap[GeneralSettingsKeys.receiptLogoPath],
        );
        _receiptFooterImagePath = _sanitizeImagePath(
          settingsMap[GeneralSettingsKeys.receiptFooterImagePath],
        );

        final rawAvailable =
            settingsMap[GeneralSettingsKeys.availableOrderTypes];
        final available =
            (rawAvailable == null || rawAvailable.trim().isEmpty)
                ? <String>[_hall, _takeaway, _delivery]
                : rawAvailable
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

        _isHallEnabled = available.contains(_hall);
        _isTakeawayEnabled = available.contains(_takeaway);
        _isDeliveryEnabled = available.contains(_delivery);
        _defaultOrderType =
            settingsMap[GeneralSettingsKeys.defaultOrderType] ?? _hall;
        _ensureDefaultOrderTypeIsEnabled();

        setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _reloadPrinters() async {
    setState(() => _isLoadingPrinters = true);
    final printerNames = await _printerService.getActivePrinterNames();
    if (!mounted) return;
    setState(() {
      _availablePrinters = printerNames;
      if (!_availablePrinters.contains(_selectedCustomerPrinter)) {
        _selectedCustomerPrinter = null;
      }
      if (!_availablePrinters.contains(_selectedKitchenPrinter)) {
        _selectedKitchenPrinter = null;
      }
      _isLoadingPrinters = false;
    });
  }

  String? _sanitizeImagePath(String? path) {
    if (path == null) return null;
    final clean = path.trim();
    if (clean.isEmpty) return null;
    return File(clean).existsSync() ? clean : null;
  }

  Future<void> _pickImage({required void Function(String?) onPicked}) async {
    try {
      const typeGroup = XTypeGroup(
        label: 'images',
        extensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return;
      onPicked(file.path);
    } catch (_) {
      final pickedPath = await _pickImageWithPowerShell();
      if (pickedPath != null && pickedPath.trim().isNotEmpty) {
        onPicked(pickedPath);
      }
    }
  }

  Future<String?> _pickImageWithPowerShell() async {
    if (!Platform.isWindows) return null;
    const script = r'''
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "Image Files|*.png;*.jpg;*.jpeg;*.webp;*.bmp"
$dialog.Multiselect = $false
$dialog.CheckFileExists = $true
$result = $dialog.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
  Write-Output $dialog.FileName
}
''';
    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ]);
      if (result.exitCode != 0) return null;
      final output = (result.stdout as String?)?.trim() ?? '';
      return output.isEmpty ? null : output;
    } catch (_) {
      return null;
    }
  }

  String? _printCountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'general_settings.invalid_print_count'.tr();
    }
    return null;
  }

  String? _taxValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.required'.tr();
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0 || parsed > 100) {
      return 'general_settings.invalid_tax_percentage'.tr();
    }
    return null;
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState?.validate() != true) return;
    final enabled = _enabledOrderTypes();
    if (enabled.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('general_settings.select_at_least_one'.tr())),
      );
      return;
    }
    if (!enabled.contains(_defaultOrderType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('general_settings.default_must_be_enabled'.tr()),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = await _getStoredUser();

    final payload = <String, String>{
      GeneralSettingsKeys.customerInvoicePrintCount:
          _customerPrintCountController.text.trim(),
      GeneralSettingsKeys.kitchenInvoicePrintCount:
          _kitchenPrintCountController.text.trim(),
      GeneralSettingsKeys.availableOrderTypes: enabled.join(','),
      GeneralSettingsKeys.defaultOrderType: _defaultOrderType,
      GeneralSettingsKeys.customerPrinterName: _selectedCustomerPrinter ?? '',
      GeneralSettingsKeys.kitchenPrinterName: _selectedKitchenPrinter ?? '',
      GeneralSettingsKeys.taxPercentage: _taxPercentageController.text.trim(),
      GeneralSettingsKeys.restaurantName: _restaurantNameController.text.trim(),
      GeneralSettingsKeys.receiptFooterSlogan:
          _footerSloganController.text.trim(),
      GeneralSettingsKeys.receiptLogoPath: _receiptLogoPath ?? '',
      GeneralSettingsKeys.receiptFooterImagePath: _receiptFooterImagePath ?? '',
    };

    final result = await _repo.upsertMany(settings: payload, userId: user?.id);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.failureMessage ?? 'general_settings.save_failed'.tr(),
            ),
          ),
        );
      },
      (_) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('general_settings.saved_successfully'.tr())),
        );
      },
    );
  }

  Widget _buildOrderTypeCheckbox({
    required String value,
    required bool selected,
    required String titleKey,
  }) {
    return CheckboxListTile(
      value: selected,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: CustomText(text: titleKey),
      onChanged: (next) => _onOrderTypeChanged(value, next ?? false),
    );
  }

  Widget _buildDefaultTypeChip({
    required String value,
    required String titleKey,
    required bool enabled,
  }) {
    return ChoiceChip(
      label: Text(titleKey.tr()),
      selected: _defaultOrderType == value,
      onSelected:
          enabled ? (_) => setState(() => _defaultOrderType = value) : null,
    );
  }

  Widget _buildPrinterDropdown({
    required String labelKey,
    required String hintKey,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value ?? '__none__'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelKey.tr(),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: Text(hintKey.tr()),
      items:
          _availablePrinters
              .map(
                (printerName) => DropdownMenuItem<String>(
                  value: printerName,
                  child: Text(printerName),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomText(text: key),
    );
  }

  Widget _buildImagePickerTile({
    required String labelKey,
    required String? path,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: labelKey),
          const SizedBox(height: 8),
          if (path != null && path.trim().isNotEmpty && File(path).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(path),
                height: 120,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            )
          else
            const CustomText(text: 'general_settings.no_image_selected'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomButtonWidget(
                  text: 'general_settings.pick_image',
                  onPressed: onPick,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButtonWidget(
                  text: 'general_settings.clear_image',
                  backgroundColor: Colors.grey.shade600,
                  onPressed: onClear,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'general-settings'),
      body: CustomPadding(
        child:
            _isLoading
                ? const CustomLoading()
                : _errorMessage != null
                ? CustomFailedWidget(
                  message: _errorMessage!,
                  onRetry: _loadSettings,
                )
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildSectionTitle('general_settings.general_section'),
                      CustomTextField(
                        title: 'general_settings.restaurant_name',
                        hint: 'general_settings.restaurant_name',
                        controller: _restaurantNameController,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        title: 'general_settings.footer_slogan',
                        hint: 'general_settings.footer_slogan',
                        controller: _footerSloganController,
                      ),
                      const SizedBox(height: 12),
                      _buildImagePickerTile(
                        labelKey: 'general_settings.receipt_logo',
                        path: _receiptLogoPath,
                        onPick:
                            () => _pickImage(
                              onPicked:
                                  (newPath) => setState(
                                    () => _receiptLogoPath = newPath,
                                  ),
                            ),
                        onClear: () => setState(() => _receiptLogoPath = null),
                      ),
                      const SizedBox(height: 12),
                      _buildImagePickerTile(
                        labelKey: 'general_settings.receipt_footer_image',
                        path: _receiptFooterImagePath,
                        onPick:
                            () => _pickImage(
                              onPicked:
                                  (newPath) => setState(
                                    () => _receiptFooterImagePath = newPath,
                                  ),
                            ),
                        onClear:
                            () =>
                                setState(() => _receiptFooterImagePath = null),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('general_settings.print_section'),
                      CustomTextField(
                        title: 'general_settings.customer_invoice_print_count',
                        hint: 'general_settings.customer_invoice_print_count',
                        controller: _customerPrintCountController,
                        isOnlyNumbers: true,
                        validator: _printCountValidator,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        title: 'general_settings.kitchen_invoice_print_count',
                        hint: 'general_settings.kitchen_invoice_print_count',
                        controller: _kitchenPrintCountController,
                        isOnlyNumbers: true,
                        validator: _printCountValidator,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        title: 'general_settings.tax_percentage',
                        hint: 'general_settings.tax_percentage',
                        controller: _taxPercentageController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _taxValidator,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: CustomText(
                              text: 'general_settings.desktop_printers',
                            ),
                          ),
                          IconButton(
                            onPressed:
                                _isLoadingPrinters ? null : _reloadPrinters,
                            tooltip: 'general_settings.refresh_printers'.tr(),
                            icon:
                                _isLoadingPrinters
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                      if (_availablePrinters.isEmpty) ...[
                        const CustomText(
                          text: 'general_settings.no_active_printers',
                        ),
                      ] else ...[
                        _buildPrinterDropdown(
                          labelKey: 'general_settings.customer_printer',
                          hintKey: 'general_settings.select_customer_printer',
                          value: _selectedCustomerPrinter,
                          onChanged:
                              (next) => setState(
                                () => _selectedCustomerPrinter = next,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildPrinterDropdown(
                          labelKey: 'general_settings.kitchen_printer',
                          hintKey: 'general_settings.select_kitchen_printer',
                          value: _selectedKitchenPrinter,
                          onChanged:
                              (next) => setState(
                                () => _selectedKitchenPrinter = next,
                              ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      const CustomText(
                        text: 'general_settings.available_order_types',
                      ),
                      _buildOrderTypeCheckbox(
                        value: _hall,
                        selected: _isHallEnabled,
                        titleKey: 'hall',
                      ),
                      _buildOrderTypeCheckbox(
                        value: _takeaway,
                        selected: _isTakeawayEnabled,
                        titleKey: 'takeaway',
                      ),
                      _buildOrderTypeCheckbox(
                        value: _delivery,
                        selected: _isDeliveryEnabled,
                        titleKey: 'delivery',
                      ),
                      const SizedBox(height: 12),
                      const CustomText(
                        text: 'general_settings.default_order_type',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildDefaultTypeChip(
                            value: _hall,
                            titleKey: 'hall',
                            enabled: _isHallEnabled,
                          ),
                          _buildDefaultTypeChip(
                            value: _takeaway,
                            titleKey: 'takeaway',
                            enabled: _isTakeawayEnabled,
                          ),
                          _buildDefaultTypeChip(
                            value: _delivery,
                            titleKey: 'delivery',
                            enabled: _isDeliveryEnabled,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: CustomButtonWidget(
                          text: 'save',
                          isLoading: _isSaving,
                          onPressed: _isSaving ? null : _saveSettings,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
