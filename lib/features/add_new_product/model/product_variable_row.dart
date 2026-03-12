/// One variable row in the variants section: name (e.g. Size) + list of values (e.g. Large, Medium, Small).
class ProductVariableRow {
  ProductVariableRow({this.name = '', List<String>? values, int? id})
      : values = values ?? [''],
        id = id ?? _nextId++;

  static int _nextId = 0;

  final int id;
  String name;
  List<String> values;
}
