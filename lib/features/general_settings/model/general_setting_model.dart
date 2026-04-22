import '../repos/offline/general_settings_schema.dart';

class GeneralSettingModel {
  const GeneralSettingModel({
    this.id,
    required this.key,
    this.value,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String key;
  final String? value;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  factory GeneralSettingModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingModel(
      id: map[GeneralSettingsSchema.colId] as int?,
      key: map[GeneralSettingsSchema.colKey] as String? ?? '',
      value: map[GeneralSettingsSchema.colValue] as String?,
      createdBy: map[GeneralSettingsSchema.colCreatedBy] as int?,
      updatedBy: map[GeneralSettingsSchema.colUpdatedBy] as int?,
      createdAt: map[GeneralSettingsSchema.colCreatedAt] as String?,
      updatedAt: map[GeneralSettingsSchema.colUpdatedAt] as String?,
    );
  }
}
