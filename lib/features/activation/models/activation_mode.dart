enum ActivationMode {
  online('online'),
  offline('offline');

  const ActivationMode(this.value);
  final String value;

  static ActivationMode? fromValue(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    for (final mode in ActivationMode.values) {
      if (mode.value == value.trim().toLowerCase()) return mode;
    }
    return null;
  }
}
