/// Role entity matching the roles table schema.
class RoleModel {
  const RoleModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  /// Creates [RoleModel] from a database row (e.g. from sqflite query).
  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  /// Creates [RoleModel] from API JSON (e.g. snake_case keys).
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
