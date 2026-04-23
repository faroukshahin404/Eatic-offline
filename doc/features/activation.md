# Device Activation and Installation Flow

## Objective

Guarantee that each purchase key can activate the offline app on only one hardware fingerprinted device.

## High-Level Flow

1. App starts at splash.
2. Splash checks `activation_device_token` in secure storage.
3. If token is missing, user is redirected to installation.
4. If token exists, app generates current signature and compares it with the stored signature.
5. If signatures mismatch, activation data is cleared and user is redirected to installation.
6. If signatures match:
   - If installation is completed: redirect to login.
   - If installation is not completed and mode is `offline`: redirect to setup screen.
   - If installation is not completed and mode is `online`: redirect to syncing screen.

## Installation Screen Requirements

- User selects a mode: `online` or `offline`.
- User enters purchase key in `xxxx-xxxx-xxxx-xxxx` format (16 digits).
- Bottom indicator shows internet status.
- `Re-check` action revalidates internet status.
- `التالي` remains disabled when there is no internet connection.

## Activation API Contract

- Endpoint: `POST https://eatic.inote-tech.com/api/v1/licensing/activate`
- Required headers:
  - `X-Device-Serial`: purchase key value from installation screen.
  - `X-Device-Signature`: SHA-256 hash of:
    - CPU ID
    - Motherboard ID
    - MAC Address

Signature source format in code:

`UPPER(CPU_ID)|UPPER(MOTHERBOARD_ID)|UPPER(MAC_ADDRESS)` then SHA-256 as lowercase 64-char hex.

## Response Handling

### Success (`200`)

Expected payload:

- `data.token`
- `data.activation.expires_at`

On success, app stores:

- `activation_device_token`
- `activation_signature_hash`
- `activation_expires_at`
- `activation_installation_mode`
- `activation_installation_completed` = `0`

### Error (`!= 200`)

Server can return validation errors such as:

- `The signature field must be 64 characters.`
- `The signature field format is invalid.`

App extracts message + flattened validation errors and shows them to user.

## Secure Storage Keys

- `activation_device_token`
- `activation_signature_hash`
- `activation_expires_at`
- `activation_installation_mode`
- `activation_installation_completed`

## Current Architecture Added

### Activation Feature

- `ActivationDioRequest`: isolated Dio request class for activation API.
- `DeviceSignatureService`: reads hardware identifiers and computes SHA-256 signature.
- `ActivationRepository`: activation orchestration and response parsing.
- `ActivationStorageService`: secure storage read/write abstraction.
- `ActivationLaunchService`: splash startup decision logic.

### Installation Feature

- `InstallationCubit`: mode selection, key validation, connectivity checks, activation trigger.
- `InstallationScreen`: activation UI.
- `SetupScreen` and `SyncingScreen`: placeholders for next implementation phase.
- `PurchaseKeyInputFormatter`: enforces purchase key visual format.

## Notes for Next Phase

- `activation_installation_completed` is currently initialized to `0`.
- Setup/syncing implementation should update it to `1` once onboarding is fully completed.
- Logout must not delete activation keys; it should only clear user session data.
