import '../../users/model/user_model.dart';
import '../repos/offline/custody_schema.dart';

/// Custody entity matching the custody table schema.
class CustodyModel {
  const CustodyModel({
    this.id,
    this.totalWhenCreate = 0,
    this.createdAt,
    this.createdBy,
    this.isClosed = false,
    this.closedBy,
    this.totalWhenClose,
    this.userModel,
  });

  final int? id;
  final double totalWhenCreate;
  final String? createdAt;
  final int? createdBy;
  final bool isClosed;
  final int? closedBy;
  final double? totalWhenClose;

  /// Resolved user who created this custody. Not persisted — populated at runtime via [createdBy].
  final UserModel? userModel;

  factory CustodyModel.fromMap(Map<String, dynamic> map) {
    UserModel? resolvedUser;
    final userData = map['created_by_user'];
    if (userData is Map<String, dynamic>) {
      resolvedUser = UserModel.fromMap(userData);
    }
    return CustodyModel(
      id: map[CustodySchema.colId] as int?,
      totalWhenCreate:
          (map[CustodySchema.colTotalWhenCreate] as num?)?.toDouble() ?? 0,
      createdAt: map[CustodySchema.colCreatedAt] as String?,
      createdBy: map[CustodySchema.colCreatedBy] as int?,
      isClosed: (map[CustodySchema.colIsClosed] as int?) == 1,
      closedBy: map[CustodySchema.colClosedBy] as int?,
      totalWhenClose:
          (map[CustodySchema.colTotalWhenClose] as num?)?.toDouble(),
      userModel: resolvedUser,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      CustodySchema.colTotalWhenCreate: totalWhenCreate,
      CustodySchema.colCreatedAt: createdAt,
      CustodySchema.colCreatedBy: createdBy,
      CustodySchema.colIsClosed: isClosed ? 1 : 0,
      CustodySchema.colClosedBy: closedBy,
      CustodySchema.colTotalWhenClose: totalWhenClose,
    };
    if (id != null) map[CustodySchema.colId] = id;
    return map;
  }

  CustodyModel copyWith({
    int? id,
    double? totalWhenCreate,
    String? createdAt,
    int? createdBy,
    bool? isClosed,
    int? closedBy,
    double? totalWhenClose,
    UserModel? userModel,
  }) {
    return CustodyModel(
      id: id ?? this.id,
      totalWhenCreate: totalWhenCreate ?? this.totalWhenCreate,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isClosed: isClosed ?? this.isClosed,
      closedBy: closedBy ?? this.closedBy,
      totalWhenClose: totalWhenClose ?? this.totalWhenClose,
      userModel: userModel ?? this.userModel,
    );
  }
}
