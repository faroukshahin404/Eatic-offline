# Offline Setup (First-Time Database Configuration)

## Purpose

After **device activation** and when the user chose **offline** mode, the app routes to the **offline setup** wizard. This screen collects minimal restaurant configuration and writes it into the **existing local SQLite database** using the same repositories and table shapes as the rest of the app. **No database schema changes** are introduced by this feature.

For activation, secure storage keys, and splash routing, see [activation.md](./activation.md).

## Entry Point and Route

- **Route path:** `AppPaths.setup` (`/setup`)
- **Widget:** `lib/features/installation/setup_screen.dart`
- **Orchestration service:** `lib/features/installation/services/offline_setup_service.dart`

The screen resolves dependencies via `getIt` (same pattern as the rest of the app).

## User Flow (3 Steps)

The UI is a simple stepper with **Back**, **Next**, and **Finish** (on the last step). Each step validates required fields before calling the service layer.

### Step 1 — Restaurant and Branches

**Inputs**

- **Restaurant name** (required)
- **Branches count** (integer; clamped between **1** and **30**)
- **One text field per branch** for the branch name (list length follows the count)

**Defaults**

- Branch count defaults to `1`
- First branch name defaults to `الفرع الرئيسي`
- Additional branches default to `فرع {n}` when the count increases

**Persistence (on successful Next)**

Handled by `OfflineSetupService.saveStepOne`:

1. Inserts each branch via `AddNewBranchOfflineRepository.create` using `BranchModel` (same insert map as elsewhere).
2. Upserts `GeneralSettingsKeys.restaurantName` via `GeneralSettingsOfflineRepository.upsertMany` with `userId: null` (same settings mechanism as the general settings screen).

**In-memory state after success**

- `_createdBranches` is populated with inserted ids (from sqflite `insert` row ids).
- `_selectedBranchId` defaults to the **first** created branch (used in Step 3).

**Step re-entry optimization**

- `_stepOnePersisted`: if Step 1 was already saved successfully, pressing **Next** again **only advances** the UI without re-inserting branches or re-upserting the restaurant name (unless the user edits Step 1 fields, which clears the flag).

### Step 2 — Currencies, Price Lists, Payment Methods

**Currencies**

- Checkboxes for: **SAR**, **EGP**, **AED**
- At least **one** currency must be selected
- Seeds map to display names/symbols in `SetupScreen` (`SetupCurrencySeed`), then persisted as `CurrencyModel` rows

**Price lists**

- **Price lists count** (integer; clamped between **1** and **30**)
- One row per list:
  - **Name** text field
  - **Currency** dropdown limited to **currently selected** currency codes

**Defaults**

- Price list count defaults to `1`
- First price list name defaults to `القائمة الرئيسية`
- Additional lists default to `قائمة {n}` when the count increases
- Default currency for new rows follows the first selected currency code

**Payment methods**

- **FilterChips** for: `Cash`, `Wallet`, `Visa`, `Apple Pay` (multi-select)
- Optional **custom methods**: user types a name and taps **Add** (case-insensitive duplicate names are rejected in the UI)

**Persistence (on successful Next)**

Handled by `OfflineSetupService.saveStepTwo`:

1. Inserts each selected currency via `AddNewCurrencyOfflineRepository.insert` (`CurrencyModel`).
2. Builds a `currencyCode -> insertedId` map from insert results.
3. Inserts each price list via `AddNewPriceListOfflineRepository.insert` (`PriceListModel` with `currencyId` referencing the inserted currency row).
4. Inserts each selected payment method via `AddNewPaymentMethodOfflineRepository.insert` (`PaymentMethodModel`).

**Step re-entry optimization**

- `_stepTwoPersisted`: if Step 2 was already saved successfully, pressing **Next** again **only advances** without re-inserting catalog rows (unless Step 2 inputs change, which clears the flag).

### Step 3 — Admin User

**Inputs**

- Admin **code** (required)
- Admin **name** (required)
- Admin **password** (required)
- **Branch** dropdown (required): populated from branches created in Step 1

**Persistence (on Finish)**

Handled by `OfflineSetupService.saveAdminAndComplete`:

1. Inserts a `UserModel` via `AddUserOfflineRepository.create` with:
   - `roleId: 1` (**admin**; matches roles seed order in `RolesStatement.roleNames`)
   - `branchId` from the selected branch
   - `createdAt` / `updatedAt` timestamps
2. Marks installation as completed in secure storage via `ActivationStorageService.markInstallationCompleted()` (sets `activation_installation_completed` to `1`; see [activation.md](./activation.md)).

**Post-success navigation**

- Navigates to `AppPaths.login` using `context.go`.

## Dependencies (Repositories)

`OfflineSetupService` is constructed in `SetupScreen.initState()` using:

| Dependency | Purpose |
|------------|---------|
| `AddNewBranchOfflineRepository` | Insert branches |
| `GeneralSettingsOfflineRepository` | Upsert restaurant name setting |
| `AddNewCurrencyOfflineRepository` | Insert currencies |
| `AddNewPriceListOfflineRepository` | Insert price lists |
| `AddNewPaymentMethodOfflineRepository` | Insert payment methods |
| `AddUserOfflineRepository` | Insert admin user |
| `ActivationStorageService` | Mark installation completed |

All of the above are registered in `lib/services_locator/service_locator.dart`.

## Error Handling

- Repository calls return `Either<OfflineFailure, T>`.
- `OfflineSetupService` maps failures to a **human-readable `String`** returned as `Left<String, ...>` to the UI.
- `SetupScreen` shows errors using `SnackBar` via `_showMessage`.

## Operational Notes and Limitations

- **Fresh-install assumption:** Step 2 inserts currencies/price lists/payment methods without clearing existing rows. If a device already contains seeded or manually-entered rows, re-running setup may cause **unique constraint** or **duplicate business data** issues depending on DB constraints and data. The intended use is **first-time setup** after activation.
- **Step 1 branch inserts** run every time Step 1 is saved (not on every Next if `_stepOnePersisted` is true). Editing Step 1 after a successful save clears persistence flags so the user can save again (which will insert **additional** branches if names/count changed). Product behavior may need a future “replace vs append” policy if re-setup becomes a requirement.
- **Admin role id** is hard-coded to `1` as **admin** per the roles seed contract used elsewhere in the codebase.

## Related Files

- `lib/features/installation/setup_screen.dart` — UI + step state
- `lib/features/installation/services/offline_setup_service.dart` — persistence orchestration
- `lib/features/general_settings/general_settings_keys.dart` — `restaurant_name` key
- `lib/features/activation/services/activation_storage_service.dart` — installation completion flag
