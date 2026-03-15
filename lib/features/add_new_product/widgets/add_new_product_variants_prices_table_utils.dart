String priceListLabel(String? name, String? currencyName) {
  if (name != null &&
      name.isNotEmpty &&
      currencyName != null &&
      currencyName.isNotEmpty) {
    return '$name ($currencyName)';
  }
  return name ?? currencyName ?? '-';
}
