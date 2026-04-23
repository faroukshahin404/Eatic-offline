import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/widgets/custom_button_widget.dart';
import '../../core/widgets/custom_padding.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../routes/app_paths.dart';
import '../../services_locator/service_locator.dart';
import '../activation/services/activation_storage_service.dart';
import '../add_new_branch/repos/offline/add_new_branch_offline_repos.dart';
import '../add_new_currency/repos/offline/add_new_currency_offline_repos.dart';
import '../add_new_payment_method/repos/offline/add_new_payment_method_offline_repos.dart';
import '../add_new_price_list/repos/offline/add_new_price_list_offline_repos.dart';
import '../add_users/repos/offline/add_user_offline_repos.dart';
import '../branches/model/branch_model.dart';
import '../general_settings/repos/offline/general_settings_offline_repos.dart';
import 'services/offline_setup_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final OfflineSetupService _setupService;

  int _currentStep = 0;
  bool _isSaving = false;
  bool _stepOnePersisted = false;
  bool _stepTwoPersisted = false;

  // Step 1
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _branchesCountController = TextEditingController(
    text: '1',
  );
  final List<TextEditingController> _branchNameControllers = [
    TextEditingController(text: 'الفرع الرئيسي'),
  ];
  List<BranchModel> _createdBranches = const [];
  int? _selectedBranchId;

  // Step 2
  static const Map<String, SetupCurrencySeed> _currencySeeds = {
    'SAR': SetupCurrencySeed(code: 'SAR', name: 'Saudi Riyal', symbol: 'SAR'),
    'EGP': SetupCurrencySeed(
      code: 'EGP',
      name: 'Egyptian Pound',
      symbol: 'EGP',
    ),
    'AED': SetupCurrencySeed(code: 'AED', name: 'UAE Dirham', symbol: 'AED'),
  };
  final Map<String, bool> _selectedCurrencies = {
    'SAR': true,
    'EGP': false,
    'AED': false,
  };
  final TextEditingController _priceListCountController = TextEditingController(
    text: '1',
  );
  final List<_PriceListDraft> _priceListDrafts = [
    _PriceListDraft(
      controller: TextEditingController(text: 'القائمة الرئيسية'),
      currencyCode: 'SAR',
    ),
  ];
  final Map<String, bool> _defaultPaymentMethods = {
    'Cash': true,
    'Wallet': false,
    'Visa': false,
    'Apple Pay': false,
  };
  final TextEditingController _customPaymentMethodController =
      TextEditingController();
  final List<String> _customPaymentMethods = [];

  // Step 3
  final TextEditingController _adminCodeController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupService = OfflineSetupService(
      branchRepo: getIt<AddNewBranchOfflineRepository>(),
      settingsRepo: getIt<GeneralSettingsOfflineRepository>(),
      currencyRepo: getIt<AddNewCurrencyOfflineRepository>(),
      priceListRepo: getIt<AddNewPriceListOfflineRepository>(),
      paymentMethodRepo: getIt<AddNewPaymentMethodOfflineRepository>(),
      userRepo: getIt<AddUserOfflineRepository>(),
      activationStorageService: getIt<ActivationStorageService>(),
    );
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _branchesCountController.dispose();
    for (final controller in _branchNameControllers) {
      controller.dispose();
    }
    _priceListCountController.dispose();
    for (final draft in _priceListDrafts) {
      draft.controller.dispose();
    }
    _customPaymentMethodController.dispose();
    _adminCodeController.dispose();
    _adminNameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomPadding(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greyE6E9EA),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStepsIndicator(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildStepContent(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.settings_suggest_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offline Setup',
                style: AppFonts.styleBold20.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 2),
              Text(
                'Setup your restaurant data in 3 steps.',
                style: AppFonts.styleRegular14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepsIndicator() {
    return Row(
      children: [
        _stepPill(index: 0, title: 'Restaurant'),
        const SizedBox(width: 8),
        _stepPill(index: 1, title: 'Catalog'),
        const SizedBox(width: 8),
        _stepPill(index: 2, title: 'Admin'),
      ],
    );
  }

  Widget _stepPill({required int index, required String title}) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color:
              isDone
                  ? AppColors.secondary
                  : isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                isDone || isActive ? AppColors.primary : AppColors.greyE6E9EA,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 15,
              color:
                  isDone || isActive ? AppColors.primary : AppColors.greyA4ACAD,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.styleRegular12.copyWith(
                  color:
                      isDone || isActive
                          ? AppColors.primary
                          : AppColors.greyA4ACAD,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return _buildStepOne();
    }
    if (_currentStep == 1) {
      return _buildStepTwo();
    }
    return _buildStepThree();
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Restaurant and Branches',
          style: AppFonts.styleSemiBold18,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          title: 'Restaurant Name',
          hint: 'Restaurant Name',
          controller: _restaurantNameController,
          onChanged: (_) => _stepOnePersisted = false,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          title: 'Branches Count',
          hint: '1',
          controller: _branchesCountController,
          isOnlyNumbers: true,
          onChanged: _onBranchesCountChanged,
        ),
        const SizedBox(height: 12),
        ...List.generate(_branchNameControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CustomTextField(
              title: 'Branch ${index + 1}',
              hint: 'Branch Name',
              controller: _branchNameControllers[index],
              onChanged: (_) => _stepOnePersisted = false,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Currencies and Catalog', style: AppFonts.styleSemiBold18),
        const SizedBox(height: 12),
        Text('Currencies', style: AppFonts.styleSemiBold16),
        Wrap(
          spacing: 10,
          runSpacing: 2,
          children:
              _currencySeeds.keys.map((code) {
                return SizedBox(
                  width: 130,
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _selectedCurrencies[code] ?? false,
                    title: Text(code),
                    onChanged:
                        (value) => _onCurrencyToggled(code, value ?? false),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 10),
        CustomTextField(
          title: 'Pricelists Count',
          hint: '1',
          controller: _priceListCountController,
          isOnlyNumbers: true,
          onChanged: _onPriceListCountChanged,
        ),
        const SizedBox(height: 12),
        ...List.generate(_priceListDrafts.length, (index) {
          final draft = _priceListDrafts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    title: 'Pricelist ${index + 1}',
                    hint: 'Pricelist Name',
                    controller: draft.controller,
                    onChanged: (_) => _stepTwoPersisted = false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('pl_${index}_${draft.currencyCode}'),
                    initialValue: draft.currencyCode,
                    decoration: InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    items:
                        _selectedCurrencyCodes
                            .map(
                              (code) => DropdownMenuItem<String>(
                                value: code,
                                child: Text(code),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        draft.currencyCode = value;
                        _stepTwoPersisted = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Text('Payment Methods', style: AppFonts.styleSemiBold16),
        Wrap(
          spacing: 14,
          children:
              _defaultPaymentMethods.keys.map((method) {
                return FilterChip(
                  label: Text(method),
                  selected: _defaultPaymentMethods[method] ?? false,
                  onSelected: (value) {
                    setState(() {
                      _defaultPaymentMethods[method] = value;
                      _stepTwoPersisted = false;
                    });
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                title: 'Add Payment Method',
                hint: 'Type method name',
                controller: _customPaymentMethodController,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: CustomButtonWidget(
                text: 'Add',
                onPressed: _addCustomPaymentMethod,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_customPaymentMethods.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                _customPaymentMethods.map((method) {
                  return Chip(
                    label: Text(method),
                    onDeleted: () {
                      setState(() {
                        _customPaymentMethods.remove(method);
                        _stepTwoPersisted = false;
                      });
                    },
                  );
                }).toList(),
          ),
      ],
    );
  }

  Widget _buildStepThree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Admin Information', style: AppFonts.styleSemiBold18),
        const SizedBox(height: 12),
        CustomTextField(
          title: 'Admin Code',
          hint: 'e.g. 1001',
          controller: _adminCodeController,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          title: 'Admin Name',
          hint: 'Admin Name',
          controller: _adminNameController,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          title: 'Admin Password',
          hint: 'Password',
          controller: _adminPasswordController,
          isPassword: true,
          maxLength: 1,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: ValueKey(
            'branch_${_selectedBranchId}_${_createdBranches.length}',
          ),
          initialValue: _selectedBranchId,
          decoration: InputDecoration(
            labelText: 'Branch',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
          items:
              _createdBranches
                  .map(
                    (branch) => DropdownMenuItem<int>(
                      value: branch.id,
                      child: Text(branch.name),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedBranchId = value),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final isLastStep = _currentStep == 2;
    return Row(
      children: [
        if (_currentStep > 0)
          SizedBox(
            width: 120,
            child: CustomButtonWidget(
              text: 'Back',
              backgroundColor: Colors.grey.shade600,
              onPressed:
                  _isSaving ? null : () => setState(() => _currentStep -= 1),
            ),
          ),
        const Spacer(),
        SizedBox(
          width: 160,
          child: CustomButtonWidget(
            text: isLastStep ? 'Finish' : 'Next',
            onPressed: _isSaving ? null : _handleNext,
            isLoading: _isSaving,
          ),
        ),
      ],
    );
  }

  List<String> get _selectedCurrencyCodes {
    return _selectedCurrencies.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  void _onBranchesCountChanged(String value) {
    _stepOnePersisted = false;
    final count = _parseCount(value);
    _syncBranchControllers(count);
  }

  void _syncBranchControllers(int count) {
    while (_branchNameControllers.length < count) {
      final nextIndex = _branchNameControllers.length + 1;
      _branchNameControllers.add(
        TextEditingController(
          text: nextIndex == 1 ? 'الفرع الرئيسي' : 'فرع $nextIndex',
        ),
      );
    }
    while (_branchNameControllers.length > count) {
      _branchNameControllers.removeLast().dispose();
    }
    setState(() {});
  }

  void _onPriceListCountChanged(String value) {
    _stepTwoPersisted = false;
    final count = _parseCount(value);
    _syncPriceListDrafts(count);
  }

  void _syncPriceListDrafts(int count) {
    while (_priceListDrafts.length < count) {
      final nextIndex = _priceListDrafts.length + 1;
      _priceListDrafts.add(
        _PriceListDraft(
          controller: TextEditingController(
            text: nextIndex == 1 ? 'القائمة الرئيسية' : 'قائمة $nextIndex',
          ),
          currencyCode: _firstSelectedCurrencyCode,
        ),
      );
    }
    while (_priceListDrafts.length > count) {
      _priceListDrafts.removeLast().controller.dispose();
    }
    _ensurePriceListsCurrenciesValid();
    setState(() {});
  }

  int _parseCount(String raw) {
    final parsed = int.tryParse(raw.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > 30) return 30;
    return parsed;
  }

  void _onCurrencyToggled(String code, bool selected) {
    setState(() {
      _selectedCurrencies[code] = selected;
      _stepTwoPersisted = false;
      _ensurePriceListsCurrenciesValid();
    });
  }

  void _ensurePriceListsCurrenciesValid() {
    final selectedCodes = _selectedCurrencyCodes;
    final fallback = selectedCodes.isNotEmpty ? selectedCodes.first : null;
    for (final draft in _priceListDrafts) {
      if (draft.currencyCode == null ||
          !selectedCodes.contains(draft.currencyCode)) {
        draft.currencyCode = fallback;
      }
    }
  }

  String? get _firstSelectedCurrencyCode {
    final selected = _selectedCurrencyCodes;
    if (selected.isEmpty) return null;
    return selected.first;
  }

  void _addCustomPaymentMethod() {
    final value = _customPaymentMethodController.text.trim();
    if (value.isEmpty) return;
    if (_customPaymentMethods.any(
      (item) => item.toLowerCase() == value.toLowerCase(),
    )) {
      _showMessage('Payment method already exists.');
      return;
    }
    setState(() {
      _customPaymentMethods.add(value);
      _customPaymentMethodController.clear();
      _stepTwoPersisted = false;
    });
  }

  Future<void> _handleNext() async {
    if (_currentStep == 0) {
      await _persistStepOne();
      return;
    }
    if (_currentStep == 1) {
      await _persistStepTwo();
      return;
    }
    await _persistStepThree();
  }

  Future<void> _persistStepOne() async {
    final restaurantName = _restaurantNameController.text.trim();
    if (restaurantName.isEmpty) {
      _showMessage('Restaurant name is required.');
      return;
    }

    final branchNames =
        _branchNameControllers
            .map((controller) => controller.text.trim())
            .toList();
    if (branchNames.any((name) => name.isEmpty)) {
      _showMessage('All branch names are required.');
      return;
    }

    if (_stepOnePersisted) {
      setState(() => _currentStep = 1);
      return;
    }

    setState(() => _isSaving = true);
    final result = await _setupService.saveStepOne(
      restaurantName: restaurantName,
      branchNames: branchNames,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(_showMessage, (branches) {
      setState(() {
        _createdBranches = branches;
        _selectedBranchId = branches.isEmpty ? null : branches.first.id;
        _stepOnePersisted = true;
        _currentStep = 1;
      });
    });
  }

  Future<void> _persistStepTwo() async {
    final selectedCurrencyCodes = _selectedCurrencyCodes;
    if (selectedCurrencyCodes.isEmpty) {
      _showMessage('Select at least one currency.');
      return;
    }

    final invalidPriceList = _priceListDrafts.any(
      (draft) =>
          draft.controller.text.trim().isEmpty ||
          draft.currencyCode == null ||
          !selectedCurrencyCodes.contains(draft.currencyCode),
    );
    if (invalidPriceList) {
      _showMessage('Each pricelist requires a name and selected currency.');
      return;
    }

    final paymentMethods = <String>[
      ..._defaultPaymentMethods.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key),
      ..._customPaymentMethods,
    ];
    if (paymentMethods.isEmpty) {
      _showMessage('Select at least one payment method.');
      return;
    }

    if (_stepTwoPersisted) {
      setState(() => _currentStep = 2);
      return;
    }

    final currencies = selectedCurrencyCodes
        .map((code) => _currencySeeds[code]!)
        .toList(growable: false);
    final priceLists = _priceListDrafts
        .map(
          (draft) => SetupPriceListSeed(
            name: draft.controller.text.trim(),
            currencyCode: draft.currencyCode!,
          ),
        )
        .toList(growable: false);

    setState(() => _isSaving = true);
    final result = await _setupService.saveStepTwo(
      currencies: currencies,
      priceLists: priceLists,
      paymentMethods: paymentMethods,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(_showMessage, (_) {
      setState(() {
        _stepTwoPersisted = true;
        _currentStep = 2;
      });
    });
  }

  Future<void> _persistStepThree() async {
    final code = _adminCodeController.text.trim();
    final name = _adminNameController.text.trim();
    final password = _adminPasswordController.text;
    final branchId = _selectedBranchId;

    if (code.isEmpty || name.isEmpty || password.isEmpty) {
      _showMessage('Admin code, name, and password are required.');
      return;
    }
    if (branchId == null) {
      _showMessage('Select admin branch.');
      return;
    }

    setState(() => _isSaving = true);
    final result = await _setupService.saveAdminAndComplete(
      code: code,
      name: name,
      password: password,
      branchId: branchId,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(_showMessage, (_) {
      _showMessage('Setup completed successfully.');
      context.go(AppPaths.login);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PriceListDraft {
  _PriceListDraft({required this.controller, required this.currencyCode});

  final TextEditingController controller;
  String? currencyCode;
}
