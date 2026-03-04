import '../repos/offline/users_schema.dart';

/// User entity matching the users table schema.
class UserModel {
  const UserModel({
    this.id,
    required this.code,
    this.name,
    this.password,
    required this.roleId,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String code;
  final String? name;
  final String? password;
  final int roleId;
  final int? createdBy;
  final int? updatedBy;
  final String createdAt;
  final String updatedAt;

  /// Creates [UserModel] from a database row (e.g. from sqflite query).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[UsersSchema.colId] as int?,
      code: map[UsersSchema.colCode] as String,
      name: map[UsersSchema.colName] as String?,
      password: map[UsersSchema.colPassword] as String?,
      roleId: map[UsersSchema.colRoleId] as int,
      createdBy: map[UsersSchema.colCreatedBy] as int?,
      updatedBy: map[UsersSchema.colUpdatedBy] as int?,
      createdAt: map[UsersSchema.colCreatedAt] as String,
      updatedAt: map[UsersSchema.colUpdatedAt] as String,
    );
  }

  /// Creates [UserModel] from API JSON (e.g. snake_case keys: id, code, name, role_id, created_at, updated_at).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      code: json['code'] as String,
      name: json['name'] as String?,
      password: json['password'] as String?,
      roleId: json['role_id'] as int,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Converts to JSON for API requests (snake_case keys).
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'name': name,
      'password': password,
      'role_id': roleId,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Converts to a map for insert/update using DB column keys.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      UsersSchema.colCode: code,
      UsersSchema.colRoleId: roleId,
      UsersSchema.colCreatedAt: createdAt,
      UsersSchema.colUpdatedAt: updatedAt,
    };
    if (id != null) map[UsersSchema.colId] = id;
    if (name != null) map[UsersSchema.colName] = name;
    if (password != null) map[UsersSchema.colPassword] = password;
    if (createdBy != null) map[UsersSchema.colCreatedBy] = createdBy;
    if (updatedBy != null) map[UsersSchema.colUpdatedBy] = updatedBy;
    return map;
  }

  Map<String, dynamic> toInsertMap() {
    return {
      UsersSchema.colCode: code,
      UsersSchema.colName: name,
      UsersSchema.colPassword: password,
      UsersSchema.colRoleId: roleId,
      UsersSchema.colCreatedBy: createdBy,
      UsersSchema.colUpdatedBy: updatedBy,
      UsersSchema.colCreatedAt: createdAt,
      UsersSchema.colUpdatedAt: updatedAt,
    };
  }

  /// Map for update (excludes id; use in WHERE clause).
  Map<String, dynamic> toUpdateMap() {
    return {
      UsersSchema.colCode: code,
      UsersSchema.colName: name,
      UsersSchema.colPassword: password,
      UsersSchema.colRoleId: roleId,
      UsersSchema.colUpdatedBy: updatedBy,
      UsersSchema.colUpdatedAt: updatedAt,
    };
  }

  UserModel copyWith({
    int? id,
    String? code,
    String? name,
    String? password,
    int? roleId,
    int? createdBy,
    int? updatedBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      password: password ?? this.password,
      roleId: roleId ?? this.roleId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code;

  @override
  int get hashCode => Object.hash(id, code);
}
