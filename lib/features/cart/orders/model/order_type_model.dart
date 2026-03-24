
import '../repos/offline/orders_schema.dart';

class OrderTypeModel {
  const OrderTypeModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory OrderTypeModel.fromMap(Map<String, dynamic> map) {
    return OrderTypeModel(
      id: map[OrderTypesSchema.colId] as int,
      name: map[OrderTypesSchema.colName] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      OrderTypesSchema.colId: id,
      OrderTypesSchema.colName: name,
    };
  }
}