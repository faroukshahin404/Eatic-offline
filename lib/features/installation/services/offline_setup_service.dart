import 'package:dartz/dartz.dart';

import '../../../core/error/offline_error.dart';
import '../../activation/services/activation_storage_service.dart';
import '../../add_new_branch/repos/offline/add_new_branch_offline_repos.dart';
import '../../add_new_currency/repos/offline/add_new_currency_offline_repos.dart';
import '../../add_new_payment_method/repos/offline/add_new_payment_method_offline_repos.dart';
import '../../add_new_price_list/repos/offline/add_new_price_list_offline_repos.dart';
import '../../add_users/repos/offline/add_user_offline_repos.dart';
import '../../branches/model/branch_model.dart';
import '../../currencies/model/currency_model.dart';
import '../../general_settings/general_settings_keys.dart';
import '../../general_settings/repos/offline/general_settings_offline_repos.dart';
import '../../payment_methods/model/payment_method_model.dart';
import '../../price_lists/model/price_list_model.dart';
import '../../users/model/user_model.dart';

class SetupCurrencySeed {
  const SetupCurrencySeed({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;
}

class SetupPriceListSeed {
  const SetupPriceListSeed({required this.name, required this.currencyCode});

  final String name;
  final String currencyCode;
}

class OfflineSetupService {
  OfflineSetupService({
    required AddNewBranchOfflineRepository branchRepo,
    required GeneralSettingsOfflineRepository settingsRepo,
    required AddNewCurrencyOfflineRepository currencyRepo,
    required AddNewPriceListOfflineRepository priceListRepo,
    required AddNewPaymentMethodOfflineRepository paymentMethodRepo,
    required AddUserOfflineRepository userRepo,
    required ActivationStorageService activationStorageService,
  }) : _branchRepo = branchRepo,
       _settingsRepo = settingsRepo,
       _currencyRepo = currencyRepo,
       _priceListRepo = priceListRepo,
       _paymentMethodRepo = paymentMethodRepo,
       _userRepo = userRepo,
       _activationStorageService = activationStorageService;

  final AddNewBranchOfflineRepository _branchRepo;
  final GeneralSettingsOfflineRepository _settingsRepo;
  final AddNewCurrencyOfflineRepository _currencyRepo;
  final AddNewPriceListOfflineRepository _priceListRepo;
  final AddNewPaymentMethodOfflineRepository _paymentMethodRepo;
  final AddUserOfflineRepository _userRepo;
  final ActivationStorageService _activationStorageService;

  Future<Either<String, List<BranchModel>>> saveStepOne({
    required String restaurantName,
    required List<String> branchNames,
  }) async {
    final now = DateTime.now().toIso8601String();
    final createdBranches = <BranchModel>[];

    for (final name in branchNames) {
      final branchResult = await _branchRepo.create(
        BranchModel(name: name, createdAt: now, updatedAt: now),
      );
      if (branchResult.isLeft()) {
        return Left(
          _failureToMessage(
            branchResult.swap().getOrElse(() => _unknownFailure),
          ),
        );
      }
      final insertedId = branchResult.getOrElse(() => 0);
      createdBranches.add(
        BranchModel(id: insertedId, name: name, createdAt: now, updatedAt: now),
      );
    }

    final settingsResult = await _settingsRepo.upsertMany(
      settings: {GeneralSettingsKeys.restaurantName: restaurantName},
      userId: null,
    );
    if (settingsResult.isLeft()) {
      return Left(
        _failureToMessage(
          settingsResult.swap().getOrElse(() => _unknownFailure),
        ),
      );
    }

    return Right(createdBranches);
  }

  Future<Either<String, void>> saveStepTwo({
    required List<SetupCurrencySeed> currencies,
    required List<SetupPriceListSeed> priceLists,
    required List<String> paymentMethods,
  }) async {
    final currencyCodeToId = <String, int>{};

    for (final currency in currencies) {
      final result = await _currencyRepo.insert(
        CurrencyModel(
          code: currency.code,
          name: currency.name,
          symbol: currency.symbol,
        ),
      );
      if (result.isLeft()) {
        return Left(
          _failureToMessage(result.swap().getOrElse(() => _unknownFailure)),
        );
      }
      currencyCodeToId[currency.code] = result.getOrElse(() => 0);
    }

    for (final priceList in priceLists) {
      final currencyId = currencyCodeToId[priceList.currencyCode];
      if (currencyId == null) {
        return const Left('Invalid currency selected for one of price lists.');
      }
      final result = await _priceListRepo.insert(
        PriceListModel(name: priceList.name, currencyId: currencyId),
      );
      if (result.isLeft()) {
        return Left(
          _failureToMessage(result.swap().getOrElse(() => _unknownFailure)),
        );
      }
    }

    final normalizedMethods =
        paymentMethods
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();

    for (final methodName in normalizedMethods) {
      final result = await _paymentMethodRepo.insert(
        PaymentMethodModel(name: methodName),
      );
      if (result.isLeft()) {
        return Left(
          _failureToMessage(result.swap().getOrElse(() => _unknownFailure)),
        );
      }
    }

    return const Right(null);
  }

  Future<Either<String, int>> saveAdminAndComplete({
    required String code,
    required String name,
    required String password,
    required int branchId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final userResult = await _userRepo.create(
      UserModel(
        code: code,
        name: name,
        password: password,
        roleId: 1,
        branchId: branchId,
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (userResult.isLeft()) {
      return Left(
        _failureToMessage(userResult.swap().getOrElse(() => _unknownFailure)),
      );
    }

    await _activationStorageService.markInstallationCompleted();
    return Right(userResult.getOrElse(() => 0));
  }

  static final OfflineFailure _unknownFailure = OfflineFailure(
    failureMessage: 'Unknown database error',
    modelException: Object(),
  );

  String _failureToMessage(OfflineFailure failure) {
    return failure.failureMessage ?? 'Operation failed. Please try again.';
  }
}
