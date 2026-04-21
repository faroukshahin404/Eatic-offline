part of 'add_new_addon_cubit.dart';

sealed class AddNewAddonState {}

final class AddNewAddonInitial extends AddNewAddonState {}

/// Persisting create or update.
final class AddNewAddonSaving extends AddNewAddonState {}

final class AddNewAddonError extends AddNewAddonState {
  final String message;
  AddNewAddonError(this.message);
}

final class AddNewAddonSaved extends AddNewAddonState {
  final int id;
  final bool isUpdate;
  AddNewAddonSaved(this.id, {this.isUpdate = false});
}
